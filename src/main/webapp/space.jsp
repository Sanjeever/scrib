<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ include file="common/header.jsp" %>
<style>
    .user-profile {
        margin-bottom: 3rem;
        padding: 2.5rem;
        background-color: #f5f5f7;
        border-radius: 18px;
    }
    .user-profile-content {
        display: flex;
        align-items: center;
        gap: 2rem;
    }
    .user-avatar {
        width: 120px;
        height: 120px;
        border-radius: 50%;
        object-fit: cover;
        border: 2px solid #d2d2d7;
        flex-shrink: 0;
    }
    .user-avatar-placeholder {
        width: 120px;
        height: 120px;
        border-radius: 50%;
        background-color: #d2d2d7;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 3rem;
        color: #86868b;
        flex-shrink: 0;
    }
    .user-info {
        flex: 1;
    }
    .user-name {
        font-size: 2rem;
        font-weight: 600;
        color: #1d1d1f;
        margin-bottom: 0.5rem;
        letter-spacing: -0.01em;
    }
    .user-username {
        color: #86868b;
        margin-bottom: 0.75rem;
        font-size: 0.9375rem;
    }
    .user-signature {
        color: #1d1d1f;
        font-style: italic;
        margin-top: 0.75rem;
        font-size: 0.9375rem;
    }
    .blog-card {
        padding: 2rem 0;
        border-bottom: 1px solid #f5f5f7;
        transition: opacity 0.3s ease;
    }
    .blog-card:last-child {
        border-bottom: none;
    }
    .blog-card:hover {
        opacity: 0.8;
    }
    .blog-card-content {
        display: flex;
        gap: 2rem;
    }
    .blog-cover {
        width: 240px;
        height: 160px;
        object-fit: cover;
        border-radius: 12px;
        flex-shrink: 0;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
    }
    .blog-info {
        flex: 1;
        min-width: 0;
    }
    .blog-title {
        font-size: 1.5rem;
        font-weight: 600;
        color: #1d1d1f;
        margin-bottom: 0.75rem;
        letter-spacing: -0.01em;
    }
    .blog-title a {
        color: #1d1d1f;
        text-decoration: none;
        transition: color 0.3s ease;
    }
    .blog-title a:hover {
        color: #0071e3;
    }
    .blog-excerpt {
        color: #86868b;
        margin-bottom: 1.25rem;
        line-height: 1.6;
        overflow: hidden;
        text-overflow: ellipsis;
        display: -webkit-box;
        -webkit-line-clamp: 2;
        -webkit-box-orient: vertical;
        font-size: 0.9375rem;
    }
    .blog-meta {
        display: flex;
        justify-content: space-between;
        align-items: center;
        font-size: 0.8125rem;
        color: #86868b;
        flex-wrap: wrap;
        gap: 0.75rem;
    }
    .blog-meta a {
        color: #0071e3;
        text-decoration: none;
        transition: opacity 0.3s ease;
    }
    .blog-meta a:hover {
        opacity: 0.7;
    }
    .blog-tags a {
        color: #0071e3;
        text-decoration: none;
        margin-right: 0.5rem;
        transition: opacity 0.3s ease;
    }
    .blog-tags a:hover {
        opacity: 0.7;
    }
    .favorite-btn {
        background-color: #f5f5f7;
        border: 1px solid #d2d2d7;
        border-radius: 20px;
        cursor: pointer;
        font-size: 0.875rem;
        color: #1d1d1f;
        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        padding: 0.5rem 1rem;
        display: inline-flex;
        align-items: center;
        gap: 0.375rem;
        font-weight: 500;
        line-height: 1;
    }
    .favorite-btn:hover {
        background-color: #e8e8ed;
        transform: translateY(-1px);
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
    }
    .favorite-btn:active {
        transform: translateY(0);
    }
    .favorite-btn.active {
        background-color: #ffebee;
        border-color: #ff3b30;
        color: #ff3b30;
    }
    .favorite-btn.active:hover {
        background-color: #ffcdd2;
        border-color: #ff453a;
    }
    .favorite-icon {
        font-size: 1rem;
        transition: transform 0.3s ease;
    }
    .favorite-btn:hover .favorite-icon {
        transform: scale(1.1);
    }
    .empty-state {
        text-align: center;
        color: #86868b;
        padding: 4rem 2rem;
        font-size: 1.0625rem;
    }
    @media (max-width: 768px) {
        .user-profile-content {
            flex-direction: column;
            text-align: center;
        }
        .blog-card-content {
            flex-direction: column;
            gap: 1.25rem;
        }
        .blog-cover {
            width: 100%;
            height: 200px;
        }
    }
</style>
<div class="container">
    <div class="content">
        <div class="user-profile">
            <div class="user-profile-content">
                <c:choose>
                    <c:when test="${not empty requestScope.user.avatar}">
                        <img src="${pageContext.request.contextPath}/${requestScope.user.avatar}" 
                             alt="头像" 
                             class="user-avatar">
                    </c:when>
                    <c:otherwise>
                        <div class="user-avatar-placeholder">
                            👤
                        </div>
                    </c:otherwise>
                </c:choose>
                <div class="user-info">
                    <h1 class="user-name">${requestScope.user.nickname}</h1>
                    <p class="user-username">@${requestScope.user.username}</p>
                    <c:if test="${not empty requestScope.user.signature}">
                        <p class="user-signature">${requestScope.user.signature}</p>
                    </c:if>
                </div>
            </div>
        </div>

        <c:if test="${empty requestScope.blogs}">
            <p class="empty-state">该用户还没有发布任何博客</p>
        </c:if>

        <c:forEach var="blog" items="${requestScope.blogs}">
            <div class="blog-card">
                <div class="blog-card-content">
                    <c:if test="${blog.coverImage != null}">
                        <img src="${blog.coverImage}" alt="封面" class="blog-cover">
                    </c:if>
                    <div class="blog-info">
                        <h3 class="blog-title">
                            <a href="${pageContext.request.contextPath}/blog/detail/${blog.id}">${blog.title}</a>
                        </h3>
                        <p class="blog-excerpt">
                            <%
                                cyou.mayloves.model.Blog blogItem = (cyou.mayloves.model.Blog) pageContext.findAttribute("blog");
                                if (blogItem != null && blogItem.getContent() != null) {
                                    String plainText = cyou.mayloves.util.MarkdownUtil.markdownToPlainText(blogItem.getContent());
                                    out.print(plainText);
                                }
                            %>
                        </p>
                        <div class="blog-meta">
                            <div>
                                <span>作者: <a href="${pageContext.request.contextPath}/space/${blog.userId}">${blog.author.nickname}</a></span>
                                <span style="margin-left: 1rem;">收藏: ${blog.favoriteCount != null ? blog.favoriteCount : 0}</span>
                                <c:if test="${not empty blog.publishTime}">
                                    <span style="margin-left: 1rem;">${blog.publishTime.toString().replace('T', ' ').substring(0, 16)}</span>
                                </c:if>
                                <c:if test="${not empty blog.tags}">
                                    <span class="blog-tags" style="margin-left: 1rem;">
                                        <c:forEach var="tag" items="${blog.tags}">
                                            <a href="${pageContext.request.contextPath}/search?tagId=${tag.id}">#${tag.name}</a>
                                        </c:forEach>
                                    </span>
                                </c:if>
                            </div>
                            <c:if test="${sessionScope.user != null}">
                                <button onclick="toggleFavorite(${blog.id}, ${blog.isFavorited != null && blog.isFavorited})" 
                                        class="favorite-btn ${blog.isFavorited != null && blog.isFavorited ? 'active' : ''}">
                                    <span class="favorite-icon">${blog.isFavorited != null && blog.isFavorited ? '♥' : '♡'}</span>
                                    <span>${blog.isFavorited != null && blog.isFavorited ? '已收藏' : '收藏'}</span>
                                </button>
                            </c:if>
                        </div>
                    </div>
                </div>
            </div>
        </c:forEach>
    </div>
</div>

<script>
function toggleFavorite(blogId, isFavorited) {
    const action = isFavorited ? 'remove' : 'add';
    fetch('${pageContext.request.contextPath}/favorite', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'action=' + action + '&blogId=' + blogId
    }).then(response => response.json())
      .then(data => {
          if (data.success) {
              location.reload();
          }
      });
}
</script>
<%@ include file="common/footer.jsp" %>

