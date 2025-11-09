package cyou.mayloves.servlet;

import cyou.mayloves.dao.UserDAO;
import cyou.mayloves.model.User;
import cyou.mayloves.util.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.util.UUID;

/**
 * 个人信息维护 Servlet
 */
@WebServlet("/profile")
@MultipartConfig(maxFileSize = 5 * 1024 * 1024) // 最大 5 MB
public class UserProfileServlet extends HttpServlet {
    private static final String UPLOAD_DIR = "uploads";
    private UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (User) (session != null ? session.getAttribute("user") : null);

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // 重新加载用户信息，确保获取最新数据
        User currentUser = userDAO.findById(user.getId());
        if (currentUser != null) {
            request.setAttribute("user", currentUser);
        } else {
            request.setAttribute("user", user);
        }

        // 传递 type 参数
        String type = request.getParameter("type");
        if (type != null) {
            request.setAttribute("type", type);
        }

        request.getRequestDispatcher("/profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (User) (session != null ? session.getAttribute("user") : null);

        if (user == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "请先登录");
            return;
        }

        // 检查是更改密码还是更新资料
        String action = request.getParameter("action");
        if ("changePassword".equals(action)) {
            handleChangePassword(request, response, user);
            return;
        }

        // 获取表单参数
        String nickname = request.getParameter("nickname");
        String signature = request.getParameter("signature");

        // 处理头像上传
        Part avatarPart = request.getPart("avatar");
        String avatarPath = null;

        if (avatarPart != null && avatarPart.getSize() > 0) {
            String fileName = avatarPart.getSubmittedFileName();
            if (fileName != null && !fileName.isEmpty()) {
                // 检查文件类型（只允许图片）
                String contentType = avatarPart.getContentType();
                if (contentType != null && contentType.startsWith("image/")) {
                    // 生成唯一文件名
                    String extension = "";
                    int dotIndex = fileName.lastIndexOf('.');
                    if (dotIndex > 0) {
                        extension = fileName.substring(dotIndex);
                    }
                    String uniqueFileName = UUID.randomUUID().toString() + extension;

                    // 确定上传目录
                    String uploadPath = UPLOAD_DIR + File.separator + "avatars";
                    String realPath = getServletContext().getRealPath(uploadPath);
                    File uploadDir = new File(realPath);
                    if (!uploadDir.exists()) {
                        uploadDir.mkdirs();
                    }

                    // 保存文件
                    File file = new File(uploadDir, uniqueFileName);
                    try (var inputStream = avatarPart.getInputStream()) {
                        Files.copy(inputStream, file.toPath(), StandardCopyOption.REPLACE_EXISTING);
                    }

                    // 设置头像路径
                    avatarPath = uploadPath + File.separator + uniqueFileName;
                } else {
                    request.setAttribute("error", "头像必须是图片文件");
                    doGet(request, response);
                    return;
                }
            }
        }

        // 更新用户信息
        User currentUser = userDAO.findById(user.getId());
        if (currentUser == null) {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "用户不存在");
            return;
        }

        // 更新字段
        if (nickname != null && !nickname.trim().isEmpty()) {
            currentUser.setNickname(nickname.trim());
        }
        if (signature != null) {
            currentUser.setSignature(signature.trim());
        }
        if (avatarPath != null) {
            // 删除旧头像
            if (currentUser.getAvatar() != null && !currentUser.getAvatar().isEmpty()) {
                String oldAvatarPath = getServletContext().getRealPath(currentUser.getAvatar());
                File oldAvatarFile = new File(oldAvatarPath);
                if (oldAvatarFile.exists()) {
                    oldAvatarFile.delete();
                }
            }
            currentUser.setAvatar(avatarPath);
        }

        // 保存到数据库
        if (userDAO.update(currentUser)) {
            // 更新 Session 中的用户信息
            session.setAttribute("user", currentUser);
            request.setAttribute("success", "个人信息更新成功");
        } else {
            request.setAttribute("error", "个人信息更新失败，请重试");
        }

        request.setAttribute("user", currentUser);
        request.getRequestDispatcher("/profile.jsp").forward(request, response);
    }

    /**
     * 处理更改密码
     */
    private void handleChangePassword(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {
        String oldPassword = request.getParameter("oldPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        // 验证输入
        if (oldPassword == null || oldPassword.trim().isEmpty()) {
            request.setAttribute("error", "请输入当前密码");
            request.setAttribute("type", "password");
            doGet(request, response);
            return;
        }

        if (newPassword == null || newPassword.trim().isEmpty() || newPassword.length() < 6) {
            request.setAttribute("error", "新密码长度至少6位");
            request.setAttribute("type", "password");
            doGet(request, response);
            return;
        }

        if (!newPassword.equals(confirmPassword)) {
            request.setAttribute("error", "两次输入的新密码不一致");
            request.setAttribute("type", "password");
            doGet(request, response);
            return;
        }

        // 验证当前密码
        User currentUser = userDAO.findById(user.getId());
        if (currentUser == null) {
            request.setAttribute("error", "用户不存在");
            request.setAttribute("type", "password");
            doGet(request, response);
            return;
        }

        String oldPasswordHash = PasswordUtil.md5(oldPassword);
        if (!oldPasswordHash.equals(currentUser.getPassword())) {
            request.setAttribute("error", "当前密码不正确");
            request.setAttribute("type", "password");
            doGet(request, response);
            return;
        }

        // 更新密码
        String newPasswordHash = PasswordUtil.md5(newPassword);
        if (userDAO.updatePassword(user.getId(), newPasswordHash)) {
            request.setAttribute("success", "密码更改成功");
            request.setAttribute("type", "password");
        } else {
            request.setAttribute("error", "密码更改失败，请重试");
            request.setAttribute("type", "password");
        }

        // 重新加载用户信息
        User updatedUser = userDAO.findById(user.getId());
        if (updatedUser != null) {
            request.setAttribute("user", updatedUser);
        } else {
            request.setAttribute("user", currentUser);
        }

        doGet(request, response);
    }
}

