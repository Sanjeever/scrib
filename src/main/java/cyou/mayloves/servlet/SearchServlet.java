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
 * 搜索 Servlet
 */
@WebServlet("/search")
public class SearchServlet extends HttpServlet {
    private BlogDAO blogDAO = new BlogDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String keyword = request.getParameter("keyword");
        String tagIdParam = request.getParameter("tagId");

        // 获取当前用户
        HttpSession session = request.getSession(false);
        User currentUser = null;
        if (session != null) {
            currentUser = (User) session.getAttribute("user");
        }

        List<Blog> blogs = null;
        if (tagIdParam != null && !tagIdParam.trim().isEmpty()) {
            // 按标签 ID 搜索
            try {
                Long tagId = Long.parseLong(tagIdParam);
                blogs = blogDAO.searchByTag(tagId);
            } catch (NumberFormatException e) {
                // 忽略
            }
        } else if (keyword != null && !keyword.trim().isEmpty()) {
            // 同时搜索标题和标签名称
            blogs = blogDAO.searchByTitleOrTag(keyword.trim());
        }

        if (blogs == null) {
            blogs = List.of();
        }

        // 设置收藏量和收藏状态
        cyou.mayloves.dao.FavoriteDAO favoriteDAO = new cyou.mayloves.dao.FavoriteDAO();
        for (Blog blog : blogs) {
            blog.setFavoriteCount(favoriteDAO.getFavoriteCount(blog.getId()));
            if (currentUser != null) {
                blog.setIsFavorited(favoriteDAO.exists(currentUser.getId(), blog.getId()));
            }
        }

        request.setAttribute("blogs", blogs);
        request.setAttribute("keyword", keyword);
        request.setAttribute("tagId", tagIdParam);
        request.getRequestDispatcher("/search.jsp").forward(request, response);
    }
}

