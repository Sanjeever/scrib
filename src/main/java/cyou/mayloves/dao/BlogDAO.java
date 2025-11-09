package cyou.mayloves.dao;

import cyou.mayloves.model.Blog;
import cyou.mayloves.util.DBUtil;

import java.sql.*;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

/**
 * 博客 DAO
 */
public class BlogDAO {
    private UserDAO userDAO = new UserDAO();
    private TagDAO tagDAO = new TagDAO();

    /**
     * 根据 ID 查找博客
     */
    public Blog findById(Long id) {
        return findById(id, null);
    }

    /**
     * 根据 ID 查找博客
     */
    public Blog findById(Long id, Long currentUserId) {
        String sql = "SELECT * FROM blogs WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setLong(1, id);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    Blog blog = mapResultSetToBlog(rs);
                    // 加载作者信息
                    blog.setAuthor(userDAO.findById(blog.getUserId()));
                    // 加载标签
                    blog.setTags(tagDAO.findByBlogId(id));
                    // 检查是否收藏
                    if (currentUserId != null) {
                        blog.setIsFavorited(new cyou.mayloves.dao.FavoriteDAO().exists(currentUserId, id));
                    }
                    return blog;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * 根据用户 ID 查找博客列表
     */
    public List<Blog> findByUserId(Long userId, Integer status) {
        String sql = "SELECT * FROM blogs WHERE user_id = ?";
        if (status != null) {
            sql += " AND status = ?";
        }
        sql += " ORDER BY create_time DESC";
        List<Blog> blogs = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setLong(1, userId);
            if (status != null) {
                pstmt.setInt(2, status);
            }
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Blog blog = mapResultSetToBlog(rs);
                    blog.setAuthor(userDAO.findById(userId));
                    blog.setTags(tagDAO.findByBlogId(blog.getId()));
                    blogs.add(blog);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return blogs;
    }

    /**
     * 查找已发布的博客列表
     */
    public List<Blog> findPublished(int offset, int limit) {
        String sql = "SELECT * FROM blogs WHERE status = 1 ORDER BY views DESC, publish_time DESC LIMIT ?, ?";
        List<Blog> blogs = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, offset);
            pstmt.setInt(2, limit);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Blog blog = mapResultSetToBlog(rs);
                    blog.setAuthor(userDAO.findById(blog.getUserId()));
                    blog.setTags(tagDAO.findByBlogId(blog.getId()));
                    blogs.add(blog);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return blogs;
    }

    /**
     * 根据标题搜索
     */
    public List<Blog> searchByTitle(String keyword) {
        String sql = "SELECT * FROM blogs WHERE status = 1 AND title LIKE ? ORDER BY views DESC, publish_time DESC";
        List<Blog> blogs = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, "%" + keyword + "%");
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Blog blog = mapResultSetToBlog(rs);
                    blog.setAuthor(userDAO.findById(blog.getUserId()));
                    blog.setTags(tagDAO.findByBlogId(blog.getId()));
                    blogs.add(blog);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return blogs;
    }

    /**
     * 根据标签搜索
     */
    public List<Blog> searchByTag(Long tagId) {
        String sql = "SELECT b.* FROM blogs b " +
                "INNER JOIN blog_tags bt ON b.id = bt.blog_id " +
                "WHERE b.status = 1 AND bt.tag_id = ? " +
                "ORDER BY b.views DESC, b.publish_time DESC";
        List<Blog> blogs = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setLong(1, tagId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Blog blog = mapResultSetToBlog(rs);
                    blog.setAuthor(userDAO.findById(blog.getUserId()));
                    blog.setTags(tagDAO.findByBlogId(blog.getId()));
                    blogs.add(blog);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return blogs;
    }

    /**
     * 同时搜索标题和标签名称
     *
     * @param keyword 搜索关键词
     * @return 匹配的博客列表（标题或标签包含关键词）
     */
    public List<Blog> searchByTitleOrTag(String keyword) {
        // 使用 UNION 合并标题搜索和标签搜索的结果，并去重
        String sql = "SELECT DISTINCT b.* FROM blogs b " +
                "LEFT JOIN blog_tags bt ON b.id = bt.blog_id " +
                "LEFT JOIN tags t ON bt.tag_id = t.id " +
                "WHERE b.status = 1 " +
                "AND (b.title LIKE ? OR t.name LIKE ?) " +
                "ORDER BY b.views DESC, b.publish_time DESC";
        List<Blog> blogs = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            String pattern = "%" + keyword + "%";
            pstmt.setString(1, pattern);
            pstmt.setString(2, pattern);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Blog blog = mapResultSetToBlog(rs);
                    blog.setAuthor(userDAO.findById(blog.getUserId()));
                    blog.setTags(tagDAO.findByBlogId(blog.getId()));
                    blogs.add(blog);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return blogs;
    }

    /**
     * 创建博客
     */
    public boolean create(Blog blog) {
        String sql;
        if (blog.getPublishTime() != null && blog.getUpdateTime() != null) {
            // 首次发布，同时设置 publish_time 和 update_time
            sql = "INSERT INTO blogs (user_id, title, content, cover_image, status, views, publish_time, update_time) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        } else {
            // 草稿，不设置 publish_time 和 update_time
            sql = "INSERT INTO blogs (user_id, title, content, cover_image, status, views, publish_time, update_time) VALUES (?, ?, ?, ?, ?, ?, NULL, NULL)";
        }
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            pstmt.setLong(1, blog.getUserId());
            pstmt.setString(2, blog.getTitle());
            pstmt.setString(3, blog.getContent());
            pstmt.setString(4, blog.getCoverImage());
            pstmt.setInt(5, blog.getStatus() != null ? blog.getStatus() : 0);
            pstmt.setInt(6, blog.getViews() != null ? blog.getViews() : 0);
            if (blog.getPublishTime() != null && blog.getUpdateTime() != null) {
                // 首次发布，同时设置 publish_time 和 update_time
                DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
                pstmt.setString(7, blog.getPublishTime().format(formatter));
                pstmt.setString(8, blog.getUpdateTime().format(formatter));
            }
            // 草稿，不设置 publish_time 和 update_time
            int rows = pstmt.executeUpdate();
            if (rows > 0) {
                try (ResultSet rs = pstmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        blog.setId(rs.getLong(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * 更新博客
     *
     * @param blog           博客对象
     * @param isFirstPublish 是否是首次发布（从草稿变为已发布）
     *                       <p>
     *                       更新逻辑：
     *                       情况1：从未发布过，点击发布按钮，同时更新 publish_time 和 update_time
     *                       情况2：从未发布过，点击保存为草稿按钮，publish_time 和 update_time 都应该置空
     *                       情况3：发布过了，更新博客并点击发布按钮（重新编辑并发布），保持 publish_time 不变，更新 update_time
     *                       情况4：发布过了，更新博客并点击保存为草稿（下架），保持 publish_time 不变，更新 update_time
     */
    public boolean update(Blog blog, boolean isFirstPublish) {
        String sql = "UPDATE blogs SET title = ?, content = ?, cover_image = ?, status = ?";

        // 先查询当前博客的 publish_time，判断是否已经发布过
        Blog existingBlog = findById(blog.getId());
        boolean hasPublishTime = existingBlog != null && existingBlog.getPublishTime() != null;

        if (isFirstPublish && blog.getPublishTime() != null && blog.getUpdateTime() != null) {
            // 情况1：从未发布过，点击发布按钮，同时更新 publish_time 和 update_time
            sql += ", publish_time = ?, update_time = ?";
        } else if (hasPublishTime) {
            // 情况3和4：发布过了，无论点击发布还是保存为草稿，都保持 publish_time 不变，更新 update_time
            sql += ", update_time = NOW()";
        } else {
            // 情况2：从未发布过，点击保存为草稿按钮，publish_time 和 update_time 都应该置空
            sql += ", publish_time = NULL, update_time = NULL";
        }

        sql += " WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, blog.getTitle());
            pstmt.setString(2, blog.getContent());
            pstmt.setString(3, blog.getCoverImage());
            pstmt.setInt(4, blog.getStatus() != null ? blog.getStatus() : 0);
            int paramIndex = 5;
            if (isFirstPublish && blog.getPublishTime() != null && blog.getUpdateTime() != null) {
                // 情况1：从未发布过，点击发布按钮，同时设置 publish_time 和 update_time
                DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
                pstmt.setString(paramIndex++, blog.getPublishTime().format(formatter));
                pstmt.setString(paramIndex++, blog.getUpdateTime().format(formatter));
            } else if (hasPublishTime) {
                // 情况3和4：发布过了，无论点击发布还是保存为草稿，都保持 publish_time 不变，更新 update_time
                blog.setUpdateTime(java.time.LocalDateTime.now(ZoneId.of("Asia/Shanghai")));
            }
            // 情况2：从未发布过，点击保存为草稿按钮，publish_time 和 update_time 都已经在 SQL 中设置为 NULL，不需要额外处理
            pstmt.setLong(paramIndex, blog.getId());
            int rows = pstmt.executeUpdate();
            if (rows > 0) {
                // 如果数据库自动更新了 update_time，从数据库重新读取
                if (hasPublishTime && !isFirstPublish) {
                    // 重新查询以获取数据库自动设置的 update_time
                    Blog updatedBlog = findById(blog.getId());
                    if (updatedBlog != null && updatedBlog.getUpdateTime() != null) {
                        blog.setUpdateTime(updatedBlog.getUpdateTime());
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * 删除博客
     */
    public boolean delete(Long id) {
        String sql = "DELETE FROM blogs WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setLong(1, id);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * 增加浏览量
     */
    public boolean incrementViews(Long id) {
        String sql = "UPDATE blogs SET views = views + 1 WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setLong(1, id);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * 将 ResultSet 映射为 Blog 对象
     */
    private Blog mapResultSetToBlog(ResultSet rs) throws SQLException {
        Blog blog = new Blog();
        blog.setId(rs.getLong("id"));
        blog.setUserId(rs.getLong("user_id"));
        blog.setTitle(rs.getString("title"));
        blog.setContent(rs.getString("content"));
        blog.setCoverImage(rs.getString("cover_image"));
        blog.setStatus(rs.getInt("status"));
        blog.setViews(rs.getInt("views"));
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

        String createTimeStr = rs.getString("create_time");
        if (createTimeStr != null && !createTimeStr.isEmpty()) {
            try {
                if (createTimeStr.contains(".")) {
                    createTimeStr = createTimeStr.substring(0, createTimeStr.indexOf("."));
                }
                blog.setCreateTime(LocalDateTime.parse(createTimeStr, formatter));
            } catch (Exception e) {
                Timestamp ts = rs.getTimestamp("create_time");
                if (ts != null) {
                    blog.setCreateTime(ts.toLocalDateTime());
                }
            }
        }

        // 读取 update_time
        String updateTimeStr = rs.getString("update_time");
        if (updateTimeStr != null && !updateTimeStr.isEmpty()) {
            try {
                if (updateTimeStr.contains(".")) {
                    updateTimeStr = updateTimeStr.substring(0, updateTimeStr.indexOf("."));
                }
                blog.setUpdateTime(LocalDateTime.parse(updateTimeStr, formatter));
            } catch (Exception e) {
                Timestamp ts = rs.getTimestamp("update_time");
                if (ts != null) {
                    blog.setUpdateTime(ts.toLocalDateTime());
                }
            }
        }

        // 读取 publish_time
        String publishTimeStr = rs.getString("publish_time");
        if (publishTimeStr != null && !publishTimeStr.isEmpty()) {
            try {
                if (publishTimeStr.contains(".")) {
                    publishTimeStr = publishTimeStr.substring(0, publishTimeStr.indexOf("."));
                }
                blog.setPublishTime(LocalDateTime.parse(publishTimeStr, formatter));
            } catch (Exception e) {
                Timestamp ts = rs.getTimestamp("publish_time");
                if (ts != null) {
                    blog.setPublishTime(ts.toLocalDateTime());
                }
            }
        }
        return blog;
    }
}

