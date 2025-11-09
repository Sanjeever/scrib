package cyou.mayloves.dao;

import cyou.mayloves.model.Attachment;
import cyou.mayloves.util.DBUtil;

import java.sql.*;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

/**
 * 附件 DAO
 */
public class AttachmentDAO {

    /**
     * 根据博客 ID 查找附件列表
     */
    public List<Attachment> findByBlogId(Long blogId) {
        String sql = "SELECT * FROM attachments WHERE blog_id = ? ORDER BY upload_time DESC";
        List<Attachment> attachments = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setLong(1, blogId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    attachments.add(mapResultSetToAttachment(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return attachments;
    }

    /**
     * 根据 ID 查找附件
     */
    public Attachment findById(Long id) {
        String sql = "SELECT * FROM attachments WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setLong(1, id);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToAttachment(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * 创建附件
     */
    public boolean create(Attachment attachment) {
        String sql = "INSERT INTO attachments (blog_id, file_name, file_path, file_size, file_type, upload_time) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            pstmt.setLong(1, attachment.getBlogId());
            pstmt.setString(2, attachment.getFileName());
            pstmt.setString(3, attachment.getFilePath());
            pstmt.setLong(4, attachment.getFileSize());
            pstmt.setString(5, attachment.getFileType());

            // 设置上传时间
            if (attachment.getUploadTime() != null) {
                DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
                pstmt.setString(6, attachment.getUploadTime().format(formatter));
            } else {
                pstmt.setTimestamp(6, new Timestamp(System.currentTimeMillis()));
            }

            int rows = pstmt.executeUpdate();
            if (rows > 0) {
                try (ResultSet rs = pstmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        attachment.setId(rs.getLong(1));
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
     * 删除附件
     */
    public boolean delete(Long id) {
        String sql = "DELETE FROM attachments WHERE id = ?";
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
     * 根据博客 ID 删除所有附件
     */
    public boolean deleteByBlogId(Long blogId) {
        String sql = "DELETE FROM attachments WHERE blog_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setLong(1, blogId);
            return pstmt.executeUpdate() >= 0; // 即使没有附件也返回true
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * 将 ResultSet 映射为 Attachment 对象
     */
    private Attachment mapResultSetToAttachment(ResultSet rs) throws SQLException {
        Attachment attachment = new Attachment();
        attachment.setId(rs.getLong("id"));
        attachment.setBlogId(rs.getLong("blog_id"));
        attachment.setFileName(rs.getString("file_name"));
        attachment.setFilePath(rs.getString("file_path"));
        attachment.setFileSize(rs.getLong("file_size"));
        attachment.setFileType(rs.getString("file_type"));

        // 读取 upload_time
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
        String uploadTimeStr = rs.getString("upload_time");
        if (uploadTimeStr != null && !uploadTimeStr.isEmpty()) {
            try {
                if (uploadTimeStr.contains(".")) {
                    uploadTimeStr = uploadTimeStr.substring(0, uploadTimeStr.indexOf("."));
                }
                attachment.setUploadTime(LocalDateTime.parse(uploadTimeStr, formatter));
            } catch (Exception e) {
                Timestamp ts = rs.getTimestamp("upload_time");
                if (ts != null) {
                    attachment.setUploadTime(ts.toLocalDateTime());
                }
            }
        }

        return attachment;
    }
}

