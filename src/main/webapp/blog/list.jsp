<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ include file="../common/header.jsp" %>
<style>
    .page-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 2.5rem;
    }
    .page-title {
        font-size: 2.5rem;
        font-weight: 600;
        color: #1d1d1f;
        letter-spacing: -0.02em;
    }
    .filter-tabs {
        margin-bottom: 2rem;
        display: flex;
        gap: 1.5rem;
        padding-bottom: 1rem;
        border-bottom: 1px solid #f5f5f7;
    }
    .filter-tab {
        color: #86868b;
        text-decoration: none;
        font-size: 0.9375rem;
        padding-bottom: 0.5rem;
        transition: all 0.3s ease;
        border-bottom: 2px solid transparent;
    }
    .filter-tab:hover {
        color: #1d1d1f;
    }
    .filter-tab.active {
        color: #0071e3;
        border-bottom-color: #0071e3;
        font-weight: 500;
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
        display: flex;
        justify-content: space-between;
        align-items: start;
        min-width: 0;
    }
    .blog-details {
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
    .draft-badge {
        background-color: #ff9500;
        color: white;
        padding: 0.25rem 0.625rem;
        border-radius: 12px;
        font-size: 0.75rem;
        font-weight: 500;
        margin-left: 0.5rem;
    }
    .blog-excerpt {
        color: #86868b;
        margin-bottom: 1.25rem;
        overflow: hidden;
        text-overflow: ellipsis;
        display: -webkit-box;
        -webkit-line-clamp: 2;
        -webkit-box-orient: vertical;
        font-size: 0.9375rem;
        line-height: 1.6;
    }
    .blog-meta {
        font-size: 0.8125rem;
        color: #86868b;
    }
    .blog-actions {
        margin-left: 1rem;
        flex-shrink: 0;
        display: flex;
        gap: 1rem;
    }
    .blog-action-link {
        color: #0071e3;
        text-decoration: none;
        font-size: 0.875rem;
        transition: opacity 0.3s ease;
    }
    .blog-action-link:hover {
        opacity: 0.7;
    }
    .blog-action-link.danger {
        color: #ff3b30;
    }
    .empty-state {
        text-align: center;
        color: #86868b;
        padding: 4rem 2rem;
        font-size: 1.0625rem;
    }
    @media (max-width: 768px) {
        .page-header {
            flex-direction: column;
            align-items: flex-start;
            gap: 1rem;
        }
        .page-title {
            font-size: 2rem;
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
        <div class="page-header">
            <h1 class="page-title">我的博客</h1>
            <a href="${pageContext.request.contextPath}/blog/new" class="btn btn-primary">写博客</a>
        </div>

        <div class="filter-tabs">
            <a href="${pageContext.request.contextPath}/blog" 
               class="filter-tab ${requestScope.status == null ? 'active' : ''}">全部</a>
            <a href="${pageContext.request.contextPath}/blog?status=1" 
               class="filter-tab ${requestScope.status == 1 ? 'active' : ''}">已发布</a>
            <a href="${pageContext.request.contextPath}/blog?status=0" 
               class="filter-tab ${requestScope.status == 0 ? 'active' : ''}">草稿</a>
        </div>

        <c:if test="${empty requestScope.blogs}">
            <p class="empty-state">暂无博客</p>
        </c:if>

        <c:forEach var="blog" items="${requestScope.blogs}">
            <div class="blog-card">
                <div class="blog-card-content">
                    <c:if test="${blog.coverImage != null}">
                        <img src="${blog.coverImage}" alt="封面" class="blog-cover">
                    </c:if>
                    <div class="blog-info">
                        <div class="blog-details">
                            <h3 class="blog-title">
                                <a href="${pageContext.request.contextPath}/blog/detail/${blog.id}">${blog.title}</a>
                                <c:if test="${blog.status == 0}">
                                    <span class="draft-badge">草稿</span>
                                </c:if>
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
                                <span>收藏: ${blog.favoriteCount != null ? blog.favoriteCount : 0}</span>
                                <c:if test="${not empty blog.publishTime}">
                                    <span style="margin-left: 1rem;">${blog.publishTime.toString().replace('T', ' ').substring(0, 16)}</span>
                                </c:if>
                                <c:if test="${not empty blog.tags}">
                                    <span style="margin-left: 1rem;">
                                        <c:forEach var="tag" items="${blog.tags}">
                                            <span style="color: #0071e3; margin-right: 0.5rem;">#${tag.name}</span>
                                        </c:forEach>
                                    </span>
                                </c:if>
                            </div>
                        </div>
                        <div class="blog-actions">
                            <a href="${pageContext.request.contextPath}/blog/edit/${blog.id}" 
                               class="blog-action-link">编辑</a>
                            <a href="${pageContext.request.contextPath}/blog/delete/${blog.id}" 
                               onclick="return confirm('确定要删除这篇博客吗？')"
                               class="blog-action-link danger">删除</a>
                        </div>
                    </div>
                </div>
            </div>
        </c:forEach>
    </div>
</div>
<%@ include file="../common/footer.jsp" %>

