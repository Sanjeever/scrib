package cyou.mayloves.servlet;

import cyou.mayloves.dao.CommentDAO;
import cyou.mayloves.model.Comment;
import cyou.mayloves.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;

/**
 * 评论 Servlet
 */
@WebServlet("/comment")
public class CommentServlet extends HttpServlet {
    private CommentDAO commentDAO = new CommentDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession(false);
        User user = (User) (session != null ? session.getAttribute("user") : null);

        if (user == null) {
            out.print("{\"success\":false,\"message\":\"请先登录\"}");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) {
            action = "add";
        }

        try {
            if ("add".equals(action)) {
                // 添加评论
                String blogIdStr = request.getParameter("blogId");
                String parentIdStr = request.getParameter("parentId");
                String content = request.getParameter("content");

                if (blogIdStr == null || content == null || content.trim().isEmpty()) {
                    out.print("{\"success\":false,\"message\":\"参数不完整\"}");
                    return;
                }

                Long blogId = Long.parseLong(blogIdStr);
                Comment comment = new Comment();
                comment.setBlogId(blogId);
                comment.setUserId(user.getId());
                comment.setContent(content.trim());

                if (parentIdStr != null && !parentIdStr.trim().isEmpty()) {
                    comment.setParentId(Long.parseLong(parentIdStr));
                }

                if (commentDAO.create(comment)) {
                    out.print("{\"success\":true,\"message\":\"评论成功\"}");
                } else {
                    out.print("{\"success\":false,\"message\":\"评论失败\"}");
                }
            } else if ("update".equals(action)) {
                // 更新评论
                String commentIdStr = request.getParameter("commentId");
                String content = request.getParameter("content");

                if (commentIdStr == null || content == null || content.trim().isEmpty()) {
                    out.print("{\"success\":false,\"message\":\"参数不完整\"}");
                    return;
                }

                Long commentId = Long.parseLong(commentIdStr);
                Comment comment = commentDAO.findById(commentId);
                if (comment == null || !comment.getUserId().equals(user.getId())) {
                    out.print("{\"success\":false,\"message\":\"无权操作此评论\"}");
                    return;
                }

                comment.setContent(content.trim());
                if (commentDAO.update(comment)) {
                    out.print("{\"success\":true,\"message\":\"更新成功\"}");
                } else {
                    out.print("{\"success\":false,\"message\":\"更新失败\"}");
                }
            } else if ("delete".equals(action)) {
                // 删除评论
                String commentIdStr = request.getParameter("commentId");
                if (commentIdStr == null) {
                    out.print("{\"success\":false,\"message\":\"参数不完整\"}");
                    return;
                }

                Long commentId = Long.parseLong(commentIdStr);
                if (commentDAO.delete(commentId, user.getId())) {
                    out.print("{\"success\":true,\"message\":\"删除成功\"}");
                } else {
                    out.print("{\"success\":false,\"message\":\"删除失败或无权限\"}");
                }
            } else {
                out.print("{\"success\":false,\"message\":\"未知操作\"}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"success\":false,\"message\":\"操作失败：" + escapeJson(e.getMessage()) + "\"}");
        }
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

