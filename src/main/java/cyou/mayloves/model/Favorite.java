package cyou.mayloves.model;

import java.time.LocalDateTime;

/**
 * 收藏实体类
 */
public class Favorite {
    private Long id;
    private Long userId;
    private Long blogId;
    private LocalDateTime createTime;

    public Favorite() {
    }

    public Favorite(Long userId, Long blogId) {
        this.userId = userId;
        this.blogId = blogId;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public Long getBlogId() {
        return blogId;
    }

    public void setBlogId(Long blogId) {
        this.blogId = blogId;
    }

    public LocalDateTime getCreateTime() {
        return createTime;
    }

    public void setCreateTime(LocalDateTime createTime) {
        this.createTime = createTime;
    }
}

