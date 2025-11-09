package cyou.mayloves.servlet;

import cyou.mayloves.dao.BlogDAO;
import cyou.mayloves.dao.TagDAO;
import cyou.mayloves.model.Blog;
import cyou.mayloves.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.ZoneId;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

/**
 * 博客管理 Servlet
 */
public class BlogServlet extends HttpServlet {
    private BlogDAO blogDAO = new BlogDAO();
    private TagDAO tagDAO = new TagDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (User) (session != null ? session.getAttribute("user") : null);
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String pathInfo = request.getPathInfo();
        String servletPath = request.getServletPath();

        if (servletPath.equals("/blog") && (pathInfo == null || pathInfo.equals("/"))) {
            // 我的博客列表 - /blog
            String statusParam = request.getParameter("status");
            Integer status = null;
            if (statusParam != null) {
                try {
                    status = Integer.parseInt(statusParam);
                } catch (NumberFormatException e) {
                    // 忽略
                }
            }
            List<Blog> blogs = blogDAO.findByUserId(user.getId(), status);
            // 设置收藏量
            cyou.mayloves.dao.FavoriteDAO favoriteDAO = new cyou.mayloves.dao.FavoriteDAO();
            for (Blog blog : blogs) {
                blog.setFavoriteCount(favoriteDAO.getFavoriteCount(blog.getId()));
            }
            request.setAttribute("blogs", blogs);
            request.setAttribute("status", status);
            request.getRequestDispatcher("/blog/list.jsp").forward(request, response);
        } else if (servletPath.equals("/blog/new")) {
            // 新建博客 - /blog/new
            request.getRequestDispatcher("/blog/edit.jsp").forward(request, response);
        } else if (servletPath.equals("/blog/edit") && pathInfo != null) {
            // 编辑博客 - /blog/edit/123
            try {
                String blogIdStr = pathInfo.startsWith("/") ? pathInfo.substring(1) : pathInfo;
                Long blogId = Long.parseLong(blogIdStr);
                Blog blog = blogDAO.findById(blogId);
                if (blog != null && blog.getUserId().equals(user.getId())) {
                    request.setAttribute("blog", blog);
                    request.getRequestDispatcher("/blog/edit.jsp").forward(request, response);
                } else {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN);
                }
            } catch (NumberFormatException e) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            }
        } else if (servletPath.equals("/blog/delete") && pathInfo != null) {
            // 删除博客 - /blog/delete/123
            try {
                String blogIdStr = pathInfo.startsWith("/") ? pathInfo.substring(1) : pathInfo;
                Long blogId = Long.parseLong(blogIdStr);
                Blog blog = blogDAO.findById(blogId);
                if (blog != null && blog.getUserId().equals(user.getId())) {
                    blogDAO.delete(blogId);
                }
                response.sendRedirect(request.getContextPath() + "/blog");
            } catch (NumberFormatException e) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            }
        } else {
            // 其他未匹配的路径返回404
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        // 预览功能不需要登录验证
        if ("preview".equals(action)) {
            // 预览 Markdown 内容
            String content = request.getParameter("content");
            String html = cyou.mayloves.util.MarkdownUtil.markdownToHtml(content != null ? content : "");
            response.setContentType("text/html;charset=UTF-8");
            response.getWriter().write(html);
            return;
        }

        // 其他操作需要登录验证
        HttpSession session = request.getSession(false);
        User user = (User) (session != null ? session.getAttribute("user") : null);
        if (user == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        String blogIdParam = request.getParameter("blogId");

        if ("save".equals(action) || "publish".equals(action)) {
            // 保存或发布博客
            Blog blog = new Blog();
            if (blogIdParam != null && !blogIdParam.trim().isEmpty()) {
                try {
                    Long blogId = Long.parseLong(blogIdParam);
                    blog = blogDAO.findById(blogId);
                    if (blog == null || !blog.getUserId().equals(user.getId())) {
                        response.sendError(HttpServletResponse.SC_FORBIDDEN);
                        return;
                    }
                } catch (NumberFormatException e) {
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST);
                    return;
                }
            }

            String title = request.getParameter("title");
            String content = request.getParameter("content");
            String coverImage = request.getParameter("coverImage");
            String tagsParam = request.getParameter("tags");

            if (title == null || title.trim().isEmpty()) {
                request.setAttribute("error", "标题不能为空");
                request.setAttribute("blog", blog);
                request.getRequestDispatcher("/blog/edit.jsp").forward(request, response);
                return;
            }

            blog.setUserId(user.getId());
            blog.setTitle(title.trim());
            blog.setContent(content != null ? content : "");
            blog.setCoverImage(coverImage != null && !coverImage.trim().isEmpty() ? coverImage.trim() : null);
            blog.setStatus("publish".equals(action) ? 1 : 0);

            if (blog.getId() == null) {
                // 新建
                // 情况1：从未发布过，点击发布按钮，同时更新 publish_time 和 update_time
                if ("publish".equals(action)) {
                    java.time.LocalDateTime now = java.time.LocalDateTime.now(ZoneId.of("Asia/Shanghai"));
                    blog.setPublishTime(now);
                    blog.setUpdateTime(now);
                }
                // 情况2：从未发布过，点击保存为草稿按钮，publish_time 和 update_time 都应该置空
                if (blogDAO.create(blog)) {
                    // 设置标签
                    if (tagsParam != null && !tagsParam.trim().isEmpty()) {
                        List<String> tagNames = Arrays.stream(tagsParam.split(","))
                                .map(String::trim)
                                .filter(s -> !s.isEmpty())
                                .collect(Collectors.toList());
                        tagDAO.setBlogTags(blog.getId(), tagNames);
                    }
                    response.sendRedirect(request.getContextPath() + "/blog");
                } else {
                    request.setAttribute("error", "保存失败");
                    request.setAttribute("blog", blog);
                    request.getRequestDispatcher("/blog/edit.jsp").forward(request, response);
                }
            } else {
                // 更新
                // 判断是否已经发布过
                boolean hasPublished = blog.getPublishTime() != null;

                // 情况3：发布过了，更新博客并点击发布按钮，保持 publish_time 不变，更新 update_time
                // 情况4：发布过了，更新博客并点击保存为草稿，保持 publish_time 不变，更新 update_time
                // 情况1（更新时）：从未发布过，点击发布按钮，同时更新 publish_time 和 update_time
                boolean isFirstPublish = "publish".equals(action) && !hasPublished;
                if (isFirstPublish) {
                    // 首次发布，设置publish_time和update_time为当前时间
                    java.time.LocalDateTime now = java.time.LocalDateTime.now(ZoneId.of("Asia/Shanghai"));
                    blog.setPublishTime(now);
                    blog.setUpdateTime(now);
                }
                // 情况2（更新时）：从未发布过，点击保存为草稿按钮，publish_time 和 update_time 都应该置空
                // 这个逻辑在 BlogDAO.update 中处理
                if (blogDAO.update(blog, isFirstPublish)) {
                    // 设置标签
                    if (tagsParam != null && !tagsParam.trim().isEmpty()) {
                        List<String> tagNames = Arrays.stream(tagsParam.split(","))
                                .map(String::trim)
                                .filter(s -> !s.isEmpty())
                                .collect(Collectors.toList());
                        tagDAO.setBlogTags(blog.getId(), tagNames);
                    }
                    response.sendRedirect(request.getContextPath() + "/blog");
                } else {
                    request.setAttribute("error", "保存失败");
                    request.setAttribute("blog", blog);
                    request.getRequestDispatcher("/blog/edit.jsp").forward(request, response);
                }
            }
        } else {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
        }
    }
}

