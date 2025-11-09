package cyou.mayloves.dao;

import cyou.mayloves.model.Blog;
import cyou.mayloves.model.Favorite;
import cyou.mayloves.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * 收藏 DAO
 */
public class FavoriteDAO {

    /**
     * 检查是否已收藏
     */
    public boolean exists(Long userId, Long blogId) {
        String sql = "SELECT COUNT(*) FROM favorites WHERE user_id = ? AND blog_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setLong(1, userId);
            pstmt.setLong(2, blogId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * 添加收藏
     */
    public boolean add(Long userId, Long blogId) {
        if (exists(userId, blogId)) {
            return true; // 已收藏，返回成功
        }
        String sql = "INSERT INTO favorites (user_id, blog_id) VALUES (?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setLong(1, userId);
            pstmt.setLong(2, blogId);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * 取消收藏
     */
    public boolean remove(Long userId, Long blogId) {
        String sql = "DELETE FROM favorites WHERE user_id = ? AND blog_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setLong(1, userId);
            pstmt.setLong(2, blogId);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * 根据用户 ID 查找收藏列表
     */
    public List<Favorite> findByUserId(Long userId) {
        String sql = "SELECT * FROM favorites WHERE user_id = ? ORDER BY create_time DESC";
        List<Favorite> favorites = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setLong(1, userId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    favorites.add(mapResultSetToFavorite(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return favorites;
    }

    /**
     * 根据用户 ID 查找收藏的博客列表
     */
    public List<Blog> findBlogsByUserId(Long userId) {
        // 先获取收藏列表
        List<Favorite> favorites = findByUserId(userId);
        List<Blog> blogs = new ArrayList<>();
        BlogDAO blogDAO = new BlogDAO();

        // 遍历收藏列表，获取每个博客的详细信息
        for (Favorite favorite : favorites) {
            Blog blog = blogDAO.findById(favorite.getBlogId(), userId);
            if (blog != null && blog.getStatus() == 1) {
                // 只显示已发布的博客
                // 标记为已收藏
                blog.setIsFavorited(true);
                blogs.add(blog);
            }
        }

        return blogs;
    }

    /**
     * 获取博客的收藏数量
     */
    public int getFavoriteCount(Long blogId) {
        String sql = "SELECT COUNT(*) FROM favorites WHERE blog_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setLong(1, blogId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * 将 ResultSet 映射为 Favorite 对象
     */
    private Favorite mapResultSetToFavorite(ResultSet rs) throws SQLException {
        Favorite favorite = new Favorite();
        favorite.setId(rs.getLong("id"));
        favorite.setUserId(rs.getLong("user_id"));
        favorite.setBlogId(rs.getLong("blog_id"));
        Timestamp createTime = rs.getTimestamp("create_time");
        if (createTime != null) {
            favorite.setCreateTime(createTime.toLocalDateTime());
        }
        return favorite;
    }
}

