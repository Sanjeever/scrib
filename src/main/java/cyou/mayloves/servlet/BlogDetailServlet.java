package cyou.mayloves.servlet;

import cyou.mayloves.dao.AttachmentDAO;
import cyou.mayloves.dao.BlogDAO;
import cyou.mayloves.dao.CommentDAO;
import cyou.mayloves.model.Blog;
import cyou.mayloves.model.User;
import cyou.mayloves.util.MarkdownUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * 博客详情 Servlet
 */
public class BlogDetailServlet extends HttpServlet {
    private BlogDAO blogDAO = new BlogDAO();

    @Override
    public void init() throws ServletException {
        super.init();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        if (pathInfo == null || pathInfo.equals("/")) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        try {
            Long blogId = Long.parseLong(pathInfo.substring(1));

            // 获取当前用户
            HttpSession session = request.getSession(false);
            User currentUser = null;
            if (session != null) {
                currentUser = (User) session.getAttribute("user");
            }

            // 先尝试查找博客
            Blog blog = blogDAO.findById(blogId, null);
            if (blog == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }

            // 检查权限：只有已发布的博客才能查看，或者是作者本人可以查看草稿
            boolean isAuthor = currentUser != null && blog.getUserId().equals(currentUser.getId());
            if (blog.getStatus() == 0 && !isAuthor) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }

            // 如果是作者或已发布，重新加载博客以获取收藏信息（如果用户已登录）
            if (currentUser != null) {
                blog = blogDAO.findById(blogId, currentUser.getId());
            }

            // 增加浏览量（只有已发布的博客才增加，且同一会话中同一博客只增加一次）
            if (blog.getStatus() == 1) {
                // 使用Session标记已访问的博客，避免重复计数
                String viewedKey = "viewed_blog_" + blogId;
                HttpSession httpSession = request.getSession();
                Boolean alreadyViewed = (Boolean) httpSession.getAttribute(viewedKey);

                if (alreadyViewed == null || !alreadyViewed) {
                    // 只有在本次会话中未访问过此博客时才增加浏览量
                    blogDAO.incrementViews(blogId);
                    blog.setViews(blog.getViews() + 1);
                    // 标记为已访问
                    httpSession.setAttribute(viewedKey, true);
                } else {
                    // 如果已访问过，从数据库重新获取最新的浏览量
                    Blog updatedBlog = blogDAO.findById(blogId, currentUser != null ? currentUser.getId() : null);
                    if (updatedBlog != null) {
                        blog.setViews(updatedBlog.getViews());
                    }
                }
            }

            // 将 Markdown 转换为 HTML
            blog.setContent(MarkdownUtil.markdownToHtml(blog.getContent()));

            // 格式化发布时间为字符串，方便JSP显示
            if (blog.getPublishTime() != null) {
                String formattedPublishTime = blog.getPublishTime().toString().replace('T', ' ').substring(0, 16);
                request.setAttribute("formattedPublishTime", formattedPublishTime);
            }

            // 格式化更新时间为字符串，方便JSP显示
            if (blog.getUpdateTime() != null) {
                String formattedUpdateTime = blog.getUpdateTime().toString().replace('T', ' ').substring(0, 16);
                request.setAttribute("formattedUpdateTime", formattedUpdateTime);
            }

            // 加载附件列表
            AttachmentDAO attachmentDAO = new AttachmentDAO();
            request.setAttribute("attachments", attachmentDAO.findByBlogId(blogId));

            // 加载评论列表（只有已发布的博客才加载评论）
            if (blog.getStatus() == 1) {
                CommentDAO commentDAO = new CommentDAO();
                request.setAttribute("comments", commentDAO.findByBlogId(blogId));
            }

            request.setAttribute("blog", blog);
            request.getRequestDispatcher("/blog/detail.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}

