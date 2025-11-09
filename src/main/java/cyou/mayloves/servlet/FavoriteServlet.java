package cyou.mayloves.servlet;

import cyou.mayloves.dao.BlogDAO;
import cyou.mayloves.dao.FavoriteDAO;
import cyou.mayloves.model.Blog;
import cyou.mayloves.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

/**
 * 收藏 Servlet
 */
@WebServlet("/favorite")
public class FavoriteServlet extends HttpServlet {
    private FavoriteDAO favoriteDAO = new FavoriteDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (User) (session != null ? session.getAttribute("user") : null);
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // 获取用户收藏的博客列表
        List<Blog> favoriteBlogs = favoriteDAO.findBlogsByUserId(user.getId());
        // 设置收藏量
        for (Blog blog : favoriteBlogs) {
            blog.setFavoriteCount(favoriteDAO.getFavoriteCount(blog.getId()));
        }
        request.setAttribute("blogs", favoriteBlogs);
        request.getRequestDispatcher("/favorites.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (User) (session != null ? session.getAttribute("user") : null);
        if (user == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        String action = request.getParameter("action");
        String blogIdParam = request.getParameter("blogId");

        if (blogIdParam == null || blogIdParam.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        try {
            Long blogId = Long.parseLong(blogIdParam);

            // 验证博客存在
            Blog blog = new BlogDAO().findById(blogId);
            if (blog == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }

            if ("add".equals(action)) {
                favoriteDAO.add(user.getId(), blogId);
            } else if ("remove".equals(action)) {
                favoriteDAO.remove(user.getId(), blogId);
            } else {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST);
                return;
            }

            // 返回 JSON 响应
            response.setContentType("application/json;charset=UTF-8");
            response.getWriter().write("{\"success\":true}");
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
        }
    }
}

