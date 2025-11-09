package cyou.mayloves.servlet;

import cyou.mayloves.dao.AttachmentDAO;
import cyou.mayloves.dao.BlogDAO;
import cyou.mayloves.model.Attachment;
import cyou.mayloves.model.Blog;
import cyou.mayloves.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.time.ZoneId;
import java.util.UUID;

/**
 * 文件上传 Servlet
 */
@WebServlet("/upload")
@MultipartConfig(maxFileSize = 50 * 1024 * 1024) // 最大50MB（附件可能较大）
public class FileUploadServlet extends HttpServlet {
    private static final String UPLOAD_DIR = "uploads";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // 获取上传类型：cover（封面）、content（内容图片）或 attachment（附件）
        String type = request.getParameter("type");
        if (type == null) {
            type = "content";
        }

        Part filePart = request.getPart("file");
        if (filePart == null || filePart.getSize() == 0) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "没有上传文件");
            return;
        }

        String fileName = filePart.getSubmittedFileName();
        if (fileName == null || fileName.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "文件名不能为空");
            return;
        }

        String contentType = filePart.getContentType();
        long fileSize = filePart.getSize();

        // 如果是附件类型，需要验证登录和博客 ID
        if ("attachment".equals(type)) {
            HttpSession session = request.getSession(false);
            User user = (User) (session != null ? session.getAttribute("user") : null);
            if (user == null) {
                response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "请先登录");
                return;
            }

            String blogIdParam = request.getParameter("blogId");
            if (blogIdParam == null || blogIdParam.trim().isEmpty()) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "缺少博客ID");
                return;
            }

            try {
                Long blogId = Long.parseLong(blogIdParam);

                // 验证博客是否属于当前用户
                BlogDAO blogDAO = new BlogDAO();
                Blog blog = blogDAO.findById(blogId);
                if (blog == null) {
                    response.setContentType("application/json;charset=UTF-8");
                    response.getWriter().write("{\"success\":false,\"message\":\"博客不存在\"}");
                    return;
                }
                if (!blog.getUserId().equals(user.getId())) {
                    response.setContentType("application/json;charset=UTF-8");
                    response.getWriter().write("{\"success\":false,\"message\":\"无权操作此博客\"}");
                    return;
                }

                // 上传附件并保存到数据库
                String extension = "";
                int dotIndex = fileName.lastIndexOf('.');
                if (dotIndex > 0) {
                    extension = fileName.substring(dotIndex);
                }

                // 生成唯一文件名
                String uniqueFileName = UUID.randomUUID().toString() + extension;

                // 确定上传目录
                String uploadPath = UPLOAD_DIR + File.separator + "attachments";

                // 创建目录
                String realPath = getServletContext().getRealPath("/");
                if (realPath == null) {
                    // 如果getRealPath返回null，使用相对路径
                    realPath = System.getProperty("user.dir");
                }
                File uploadDir = new File(realPath, uploadPath);
                if (!uploadDir.exists()) {
                    uploadDir.mkdirs();
                }

                // 保存文件
                File file = new File(uploadDir, uniqueFileName);
                try (InputStream input = filePart.getInputStream()) {
                    Files.copy(input, file.toPath(), StandardCopyOption.REPLACE_EXISTING);
                }

                // 保存附件信息到数据库
                Attachment attachment = new Attachment();
                attachment.setBlogId(blogId);
                attachment.setFileName(fileName);
                String relativePath = uploadPath.replace(File.separator, "/") + "/" + uniqueFileName;
                attachment.setFilePath(relativePath);
                attachment.setFileSize(fileSize);
                attachment.setFileType(contentType);
                attachment.setUploadTime(java.time.LocalDateTime.now(ZoneId.of("Asia/Shanghai")));

                AttachmentDAO attachmentDAO = new AttachmentDAO();
                if (attachmentDAO.create(attachment)) {
                    // 返回附件信息
                    String fileUrl = request.getContextPath() + "/" + relativePath;
                    response.setContentType("application/json;charset=UTF-8");
                    response.getWriter().write("{\"success\":true,\"id\":" + attachment.getId() +
                            ",\"fileName\":\"" + escapeJson(fileName) + "\"" +
                            ",\"fileSize\":" + fileSize +
                            ",\"fileUrl\":\"" + fileUrl + "\"}");
                } else {
                    // 删除已上传的文件
                    file.delete();
                    response.setContentType("application/json;charset=UTF-8");
                    response.getWriter().write("{\"success\":false,\"message\":\"保存附件信息失败\"}");
                }
                return;
            } catch (NumberFormatException e) {
                response.setContentType("application/json;charset=UTF-8");
                response.getWriter().write("{\"success\":false,\"message\":\"无效的博客ID\"}");
                return;
            } catch (Exception e) {
                e.printStackTrace();
                response.setContentType("application/json;charset=UTF-8");
                response.getWriter().write("{\"success\":false,\"message\":\"上传失败: " + escapeJson(e.getMessage()) + "\"}");
                return;
            }
        }

        // 处理图片上传（cover或content）
        // 验证文件类型（只允许图片）
        if (contentType == null || !contentType.startsWith("image/")) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "只能上传图片文件");
            return;
        }

        // 获取文件扩展名
        String extension = "";
        int dotIndex = fileName.lastIndexOf('.');
        if (dotIndex > 0) {
            extension = fileName.substring(dotIndex);
        }

        // 生成唯一文件名
        String uniqueFileName = UUID.randomUUID().toString() + extension;

        // 确定上传目录
        String uploadPath;
        if ("cover".equals(type)) {
            uploadPath = UPLOAD_DIR + File.separator + "covers";
        } else {
            uploadPath = UPLOAD_DIR + File.separator + "content";
        }

        // 创建目录
        String realPath = getServletContext().getRealPath("/");
        File uploadDir = new File(realPath, uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }

        // 保存文件
        File file = new File(uploadDir, uniqueFileName);
        try (InputStream input = filePart.getInputStream()) {
            Files.copy(input, file.toPath(), StandardCopyOption.REPLACE_EXISTING);
        }

        // 返回文件URL（使用正斜杠，确保URL正确）
        String relativePath = uploadPath.replace(File.separator, "/") + "/" + uniqueFileName;
        String fileUrl = request.getContextPath() + "/" + relativePath;
        response.setContentType("application/json;charset=UTF-8");
        response.getWriter().write("{\"url\":\"" + fileUrl + "\"}");
    }

    /**
     * 转义 JSON 字符串中的特殊字符
     */
    private String escapeJson(String str) {
        if (str == null) {
            return "";
        }
        return str.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
}

