package cyou.mayloves.servlet;

import cyou.mayloves.dao.BlogDAO;
import cyou.mayloves.dao.UserDAO;
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
 * 用户博客空间 Servlet
 */
@WebServlet("/space/*")
public class UserSpaceServlet extends HttpServlet {
    private UserDAO userDAO = new UserDAO();
    private BlogDAO blogDAO = new BlogDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        if (pathInfo == null || pathInfo.equals("/")) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        try {
            Long userId = Long.parseLong(pathInfo.substring(1));
            User user = userDAO.findById(userId);
            if (user == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }

            // 获取该用户已发布的博客
            List<Blog> blogs = blogDAO.findByUserId(userId, 1);

            // 获取当前用户，检查收藏状态
            HttpSession session = request.getSession(false);
            User currentUser = null;
            if (session != null) {
                currentUser = (User) session.getAttribute("user");
            }

            // 设置收藏量和收藏状态
            cyou.mayloves.dao.FavoriteDAO favoriteDAO = new cyou.mayloves.dao.FavoriteDAO();
            for (Blog blog : blogs) {
                blog.setFavoriteCount(favoriteDAO.getFavoriteCount(blog.getId()));
                if (currentUser != null) {
                    blog.setIsFavorited(favoriteDAO.exists(currentUser.getId(), blog.getId()));
                }
            }

            request.setAttribute("user", user);
            request.setAttribute("blogs", blogs);
            request.getRequestDispatcher("/space.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
        }
    }
}

