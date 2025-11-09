<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ include file="common/header.jsp" %>
<style>
    .page-title {
        font-size: 2.5rem;
        font-weight: 600;
        color: #1d1d1f;
        margin-bottom: 2.5rem;
        letter-spacing: -0.02em;
    }
    .search-form {
        margin-bottom: 3rem;
    }
    .search-input {
        flex: 1;
        padding: 0.875rem 1.25rem;
        border: 1px solid #d2d2d7;
        border-radius: 12px;
        font-size: 0.9375rem;
        font-family: inherit;
        background-color: #f5f5f7;
        transition: all 0.3s ease;
        outline: none;
    }
    .search-input:focus {
        background-color: #ffffff;
        border-color: #0071e3;
        box-shadow: 0 0 0 4px rgba(0, 113, 227, 0.1);
    }
    .search-form form {
        display: flex;
        gap: 0.75rem;
    }
    .blogs-grid {
        display: grid;
        grid-template-columns: repeat(2, 1fr);
        gap: 2rem;
        margin-top: 1rem;
    }
    .blog-card {
        background-color: #ffffff;
        border-radius: 18px;
        padding: 0;
        overflow: hidden;
        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
        border: 1px solid #f5f5f7;
        display: flex;
        flex-direction: column;
    }
    .blog-card:hover {
        transform: translateY(-4px);
        box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12);
    }
    .blog-card.featured {
        grid-column: 1 / -1;
    }
    .blog-card-content {
        display: flex;
        flex-direction: column;
        height: 100%;
    }
    .blog-cover-wrapper {
        width: 100%;
        height: 200px;
        overflow: hidden;
        background-color: #f5f5f7;
        position: relative;
    }
    .blog-cover {
        width: 100%;
        height: 100%;
        object-fit: cover;
        transition: transform 0.5s ease;
    }
    .blog-card:hover .blog-cover {
        transform: scale(1.05);
    }
    .blog-card.featured .blog-cover-wrapper {
        height: 280px;
    }
    .blog-info {
        padding: 1.5rem;
        display: flex;
        flex-direction: column;
        flex: 1;
    }
    .blog-card.featured .blog-info {
        padding: 2rem;
    }
    .blog-title {
        font-size: 1.25rem;
        font-weight: 600;
        color: #1d1d1f;
        margin-bottom: 0.75rem;
        letter-spacing: -0.01em;
        line-height: 1.3;
    }
    .blog-card.featured .blog-title {
        font-size: 1.75rem;
        margin-bottom: 1rem;
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
        -webkit-line-clamp: 3;
        -webkit-box-orient: vertical;
        font-size: 0.9375rem;
        flex: 1;
    }
    .blog-card.featured .blog-excerpt {
        -webkit-line-clamp: 4;
        font-size: 1rem;
        margin-bottom: 1.5rem;
    }
    .blog-meta {
        display: flex;
        justify-content: space-between;
        align-items: center;
        font-size: 0.8125rem;
        color: #86868b;
        flex-wrap: wrap;
        gap: 0.75rem;
        margin-top: auto;
        padding-top: 1rem;
        border-top: 1px solid #f5f5f7;
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
    @media (max-width: 1024px) {
        .blogs-grid {
            grid-template-columns: 1fr;
            gap: 1.5rem;
        }
        .blog-card.featured {
            grid-column: 1;
        }
        .blog-card.featured .blog-cover-wrapper {
            height: 240px;
        }
    }
    @media (max-width: 768px) {
        .page-title {
            font-size: 2rem;
            margin-bottom: 2rem;
        }
        .blogs-grid {
            gap: 1.25rem;
        }
        .blog-cover-wrapper {
            height: 180px;
        }
        .blog-card.featured .blog-cover-wrapper {
            height: 200px;
        }
        .blog-info {
            padding: 1.25rem;
        }
        .blog-card.featured .blog-info {
            padding: 1.5rem;
        }
        .blog-title {
            font-size: 1.125rem;
        }
        .blog-card.featured .blog-title {
            font-size: 1.5rem;
        }
    }
</style>
<div class="container">
    <div class="content">
        <h1 class="page-title">热门文章</h1>
        
        <!-- 搜索框 -->
        <div class="search-form">
            <form action="${pageContext.request.contextPath}/search" method="get">
                <input type="text" name="keyword" placeholder="搜索文章标题或标签..." class="search-input">
                <button type="submit" class="btn btn-primary">搜索</button>
            </form>
        </div>

        <c:if test="${empty requestScope.blogs}">
            <p class="empty-state">暂无文章</p>
        </c:if>

        <div class="blogs-grid">
            <c:forEach var="blog" items="${requestScope.blogs}" varStatus="status">
                <div class="blog-card ${status.index < 1 ? 'featured' : ''}">
                    <div class="blog-card-content">
                        <c:if test="${blog.coverImage != null}">
                            <div class="blog-cover-wrapper">
                                <img src="${blog.coverImage}" alt="封面" class="blog-cover">
                            </div>
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

