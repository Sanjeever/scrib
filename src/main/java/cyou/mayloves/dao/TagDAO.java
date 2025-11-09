package cyou.mayloves.dao;

import cyou.mayloves.model.Tag;
import cyou.mayloves.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * 标签 DAO
 */
public class TagDAO {

    /**
     * 根据 ID 查找标签
     */
    public Tag findById(Long id) {
        String sql = "SELECT * FROM tags WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setLong(1, id);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToTag(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * 根据名称查找标签
     */
    public Tag findByName(String name) {
        String sql = "SELECT * FROM tags WHERE name = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, name);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToTag(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * 查找所有标签
     */
    public List<Tag> findAll() {
        String sql = "SELECT * FROM tags ORDER BY name";
        List<Tag> tags = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                tags.add(mapResultSetToTag(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return tags;
    }

    /**
     * 根据博客 ID 查找标签
     */
    public List<Tag> findByBlogId(Long blogId) {
        String sql = "SELECT t.* FROM tags t " +
                "INNER JOIN blog_tags bt ON t.id = bt.tag_id " +
                "WHERE bt.blog_id = ?";
        List<Tag> tags = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setLong(1, blogId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    tags.add(mapResultSetToTag(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return tags;
    }

    /**
     * 创建标签
     */
    public Tag createIfNotExists(String name) {
        Tag tag = findByName(name);
        if (tag != null) {
            return tag;
        }
        String sql = "INSERT INTO tags (name) VALUES (?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            pstmt.setString(1, name);
            int rows = pstmt.executeUpdate();
            if (rows > 0) {
                try (ResultSet rs = pstmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        tag = new Tag();
                        tag.setId(rs.getLong(1));
                        tag.setName(name);
                        return tag;
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * 设置博客标签
     */
    public boolean setBlogTags(Long blogId, List<String> tagNames) {
        // 先删除旧标签
        String deleteSql = "DELETE FROM blog_tags WHERE blog_id = ?";
        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement pstmt = conn.prepareStatement(deleteSql)) {
                pstmt.setLong(1, blogId);
                pstmt.executeUpdate();
            }

            // 添加新标签
            if (tagNames != null && !tagNames.isEmpty()) {
                String insertSql = "INSERT INTO blog_tags (blog_id, tag_id) VALUES (?, ?)";
                try (PreparedStatement pstmt = conn.prepareStatement(insertSql)) {
                    for (String tagName : tagNames) {
                        if (tagName != null && !tagName.trim().isEmpty()) {
                            Tag tag = createIfNotExists(tagName.trim());
                            if (tag != null) {
                                pstmt.setLong(1, blogId);
                                pstmt.setLong(2, tag.getId());
                                pstmt.addBatch();
                            }
                        }
                    }
                    pstmt.executeBatch();
                }
            }
            conn.commit();
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * 将 ResultSet 映射为 Tag 对象
     */
    private Tag mapResultSetToTag(ResultSet rs) throws SQLException {
        Tag tag = new Tag();
        tag.setId(rs.getLong("id"));
        tag.setName(rs.getString("name"));
        Timestamp createTime = rs.getTimestamp("create_time");
        if (createTime != null) {
            tag.setCreateTime(createTime.toLocalDateTime());
        }
        return tag;
    }
}

