package cyou.mayloves.servlet;

import cyou.mayloves.dao.BlogDAO;
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
 * 首页 Servlet
 */
@WebServlet("/home")
public class HomeServlet extends HttpServlet {
    private BlogDAO blogDAO = new BlogDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // 获取当前用户
        HttpSession session = request.getSession(false);
        User currentUser = null;
        if (session != null) {
            currentUser = (User) session.getAttribute("user");
        }

        // 获取已发布的博客列表
        List<Blog> blogs = blogDAO.findPublished(0, 1000); // 先获取足够多的博客

        // 设置收藏量和收藏状态
        cyou.mayloves.dao.FavoriteDAO favoriteDAO = new cyou.mayloves.dao.FavoriteDAO();
        for (Blog blog : blogs) {
            blog.setFavoriteCount(favoriteDAO.getFavoriteCount(blog.getId()));
            if (currentUser != null) {
                blog.setIsFavorited(favoriteDAO.exists(currentUser.getId(), blog.getId()));
            }
        }

        // 按照收藏量和 publish_time 排序
        blogs.sort((b1, b2) -> {
            // 首先按收藏量降序排序
            int favoriteCompare = Integer.compare(
                    b2.getFavoriteCount() != null ? b2.getFavoriteCount() : 0,
                    b1.getFavoriteCount() != null ? b1.getFavoriteCount() : 0
            );
            if (favoriteCompare != 0) {
                return favoriteCompare;
            }
            // 如果收藏量相同，按 publish_time 降序排序
            if (b1.getPublishTime() != null && b2.getPublishTime() != null) {
                return b2.getPublishTime().compareTo(b1.getPublishTime());
            }
            if (b1.getPublishTime() == null && b2.getPublishTime() == null) {
                return 0;
            }
            return b1.getPublishTime() == null ? 1 : -1;
        });

        // 只取前20条
        if (blogs.size() > 20) {
            blogs = blogs.subList(0, 20);
        }

        request.setAttribute("blogs", blogs);
        request.getRequestDispatcher("/home.jsp").forward(request, response);
    }
}

