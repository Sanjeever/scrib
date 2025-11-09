package cyou.mayloves.servlet;

import cyou.mayloves.dao.AttachmentDAO;
import cyou.mayloves.dao.BlogDAO;
import cyou.mayloves.model.Attachment;
import cyou.mayloves.model.Blog;
import cyou.mayloves.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.File;
import java.io.IOException;

/**
 * 附件管理 Servlet
 */
public class AttachmentServlet extends HttpServlet {
    private AttachmentDAO attachmentDAO = new AttachmentDAO();
    private BlogDAO blogDAO = new BlogDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        if (pathInfo == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        // 需要登录验证
        HttpSession session = request.getSession(false);
        User user = (User) (session != null ? session.getAttribute("user") : null);
        if (user == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        if (pathInfo.equals("/delete")) {
            // 删除附件
            String idParam = request.getParameter("id");
            if (idParam == null || idParam.trim().isEmpty()) {
                response.setContentType("application/json;charset=UTF-8");
                response.getWriter().write("{\"success\":false,\"message\":\"缺少附件ID\"}");
                return;
            }

            try {
                Long attachmentId = Long.parseLong(idParam);
                Attachment attachment = attachmentDAO.findById(attachmentId);
                if (attachment == null) {
                    response.setContentType("application/json;charset=UTF-8");
                    response.getWriter().write("{\"success\":false,\"message\":\"附件不存在\"}");
                    return;
                }

                // 验证博客是否属于当前用户
                Blog blog = blogDAO.findById(attachment.getBlogId());
                if (blog == null || !blog.getUserId().equals(user.getId())) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN);
                    return;
                }

                // 删除文件
                String realPath = getServletContext().getRealPath("/");
                File file = new File(realPath, attachment.getFilePath());
                if (file.exists()) {
                    file.delete();
                }

                // 删除数据库记录
                if (attachmentDAO.delete(attachmentId)) {
                    response.setContentType("application/json;charset=UTF-8");
                    response.getWriter().write("{\"success\":true}");
                } else {
                    response.setContentType("application/json;charset=UTF-8");
                    response.getWriter().write("{\"success\":false,\"message\":\"删除失败\"}");
                }
            } catch (NumberFormatException e) {
                response.setContentType("application/json;charset=UTF-8");
                response.getWriter().write("{\"success\":false,\"message\":\"无效的附件ID\"}");
            }
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }
}

