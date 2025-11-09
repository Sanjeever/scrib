package cyou.mayloves.dao;

import cyou.mayloves.model.Comment;
import cyou.mayloves.util.DBUtil;

import java.sql.*;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 评论 DAO
 */
public class CommentDAO {
    private UserDAO userDAO = new UserDAO();

    /**
     * 根据博客 ID 查找所有评论（包括回复）
     */
    public List<Comment> findByBlogId(Long blogId) {
        String sql = "SELECT * FROM comments WHERE blog_id = ? ORDER BY create_time ASC";
        List<Comment> allComments = new ArrayList<>();
        Map<Long, Comment> commentMap = new HashMap<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setLong(1, blogId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Comment comment = mapResultSetToComment(rs);
                    comment.setUser(userDAO.findById(comment.getUserId()));
                    commentMap.put(comment.getId(), comment);
                    allComments.add(comment);
                }
            }

            // 构建评论树结构
            List<Comment> topLevelComments = new ArrayList<>();
            for (Comment comment : allComments) {
                if (comment.getParentId() == null) {
                    // 顶级评论
                    comment.setReplies(new ArrayList<>());
                    topLevelComments.add(comment);
                } else {
                    // 回复评论
                    Comment parent = commentMap.get(comment.getParentId());
                    if (parent != null) {
                        if (parent.getReplies() == null) {
                            parent.setReplies(new ArrayList<>());
                        }
                        parent.getReplies().add(comment);
                        // 设置父评论的用户信息
                        comment.setParentUser(parent.getUser());
                    }
                }
            }

            return topLevelComments;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return new ArrayList<>();
    }

    /**
     * 根据 ID 查找评论
     */
    public Comment findById(Long id) {
        String sql = "SELECT * FROM comments WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setLong(1, id);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    Comment comment = mapResultSetToComment(rs);
                    comment.setUser(userDAO.findById(comment.getUserId()));
                    return comment;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * 创建评论
     */
    public boolean create(Comment comment) {
        String sql = "INSERT INTO comments (blog_id, user_id, parent_id, content) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            pstmt.setLong(1, comment.getBlogId());
            pstmt.setLong(2, comment.getUserId());
            if (comment.getParentId() != null) {
                pstmt.setLong(3, comment.getParentId());
            } else {
                pstmt.setNull(3, Types.BIGINT);
            }
            pstmt.setString(4, comment.getContent());
            int rows = pstmt.executeUpdate();
            if (rows > 0) {
                try (ResultSet rs = pstmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        comment.setId(rs.getLong(1));
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
     * 更新评论
     */
    public boolean update(Comment comment) {
        String sql = "UPDATE comments SET content = ? WHERE id = ? AND user_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, comment.getContent());
            pstmt.setLong(2, comment.getId());
            pstmt.setLong(3, comment.getUserId());
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * 删除评论
     */
    public boolean delete(Long id, Long userId) {
        // 检查评论是否属于当前用户
        Comment comment = findById(id);
        if (comment == null || !comment.getUserId().equals(userId)) {
            return false;
        }

        String sql = "DELETE FROM comments WHERE id = ?";
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
     * 获取评论数量
     */
    public int getCommentCount(Long blogId) {
        String sql = "SELECT COUNT(*) FROM comments WHERE blog_id = ?";
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
     * 将 ResultSet 映射为 Comment 对象
     */
    private Comment mapResultSetToComment(ResultSet rs) throws SQLException {
        Comment comment = new Comment();
        comment.setId(rs.getLong("id"));
        comment.setBlogId(rs.getLong("blog_id"));
        comment.setUserId(rs.getLong("user_id"));
        Long parentId = rs.getLong("parent_id");
        if (!rs.wasNull()) {
            comment.setParentId(parentId);
        }
        comment.setContent(rs.getString("content"));

        // 读取时间
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

        String createTimeStr = rs.getString("create_time");
        if (createTimeStr != null && !createTimeStr.isEmpty()) {
            try {
                if (createTimeStr.contains(".")) {
                    createTimeStr = createTimeStr.substring(0, createTimeStr.indexOf("."));
                }
                comment.setCreateTime(LocalDateTime.parse(createTimeStr, formatter));
            } catch (Exception e) {
                Timestamp ts = rs.getTimestamp("create_time");
                if (ts != null) {
                    comment.setCreateTime(ts.toLocalDateTime());
                }
            }
        }

        String updateTimeStr = rs.getString("update_time");
        if (updateTimeStr != null && !updateTimeStr.isEmpty()) {
            try {
                if (updateTimeStr.contains(".")) {
                    updateTimeStr = updateTimeStr.substring(0, updateTimeStr.indexOf("."));
                }
                comment.setUpdateTime(LocalDateTime.parse(updateTimeStr, formatter));
            } catch (Exception e) {
                Timestamp ts = rs.getTimestamp("update_time");
                if (ts != null) {
                    comment.setUpdateTime(ts.toLocalDateTime());
                }
            }
        }

        return comment;
    }
}

