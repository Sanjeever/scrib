<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ include file="../common/header.jsp" %>
<style>
    .article-title {
        font-size: 2.75rem;
        font-weight: 600;
        color: #1d1d1f;
        margin-bottom: 1.5rem;
        letter-spacing: -0.02em;
        line-height: 1.2;
    }
    .article-meta {
        margin-bottom: 2.5rem;
        padding-bottom: 1.5rem;
        border-bottom: 1px solid #f5f5f7;
    }
    .article-author {
        display: flex;
        align-items: center;
        margin-bottom: 1rem;
    }
    .article-avatar {
        width: 48px;
        height: 48px;
        min-width: 48px;
        min-height: 48px;
        max-width: 48px;
        max-height: 48px;
        border-radius: 50%;
        object-fit: cover;
        margin-right: 0.75rem;
        border: 1px solid #d2d2d7;
        overflow: hidden;
    }
    .article-avatar-placeholder {
        width: 48px;
        height: 48px;
        min-width: 48px;
        min-height: 48px;
        max-width: 48px;
        max-height: 48px;
        border-radius: 50%;
        background-color: #d2d2d7;
        margin-right: 0.75rem;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1.5rem;
        color: #86868b;
        overflow: hidden;
    }
    .article-author-name {
        font-weight: 600;
        color: #1d1d1f;
        font-size: 1rem;
    }
    .article-author-name a {
        color: #0071e3;
        text-decoration: none;
        transition: opacity 0.3s ease;
    }
    .article-author-name a:hover {
        opacity: 0.7;
    }
    .article-info {
        display: flex;
        align-items: center;
        flex-wrap: wrap;
        gap: 1rem;
        font-size: 0.875rem;
        color: #86868b;
        margin-bottom: 0.75rem;
    }
    .article-tags {
        margin-top: 0.75rem;
    }
    .article-tags a {
        color: #0071e3;
        text-decoration: none;
        margin-right: 0.75rem;
        font-size: 0.875rem;
        transition: opacity 0.3s ease;
    }
    .article-tags a:hover {
        opacity: 0.7;
    }
    .article-favorite-btn {
        background-color: #f5f5f7;
        border: 1px solid #d2d2d7;
        border-radius: 20px;
        cursor: pointer;
        font-size: 0.875rem;
        color: #1d1d1f;
        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        padding: 0.625rem 1.25rem;
        display: inline-flex;
        align-items: center;
        gap: 0.5rem;
        font-weight: 500;
        margin-top: 0.75rem;
    }
    .article-favorite-btn:hover {
        background-color: #e8e8ed;
        transform: translateY(-1px);
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
    }
    .article-favorite-btn:active {
        transform: translateY(0);
    }
    .article-favorite-btn.active {
        background-color: #ffebee;
        border-color: #ff3b30;
        color: #ff3b30;
    }
    .article-favorite-btn.active:hover {
        background-color: #ffcdd2;
        border-color: #ff453a;
    }
    .favorite-icon {
        font-size: 1rem;
        transition: transform 0.3s ease;
    }
    .article-favorite-btn:hover .favorite-icon {
        transform: scale(1.1);
    }
    .article-cover {
        margin-bottom: 3rem;
        text-align: center;
    }
    .article-cover img {
        max-width: 100%;
        border-radius: 18px;
        box-shadow: 0 4px 16px rgba(0, 0, 0, 0.1);
    }
    .markdown-content {
        line-height: 1.8;
        font-size: 1.125rem;
        color: #1d1d1f;
    }
    .attachments-section {
        margin-top: 4rem;
        padding-top: 2.5rem;
        border-top: 1px solid #f5f5f7;
    }
    .attachments-title {
        font-size: 1.5rem;
        font-weight: 600;
        color: #1d1d1f;
        margin-bottom: 1.5rem;
        letter-spacing: -0.01em;
    }
    .attachment-item {
        display: flex;
        align-items: center;
        padding: 1.25rem;
        background-color: #f5f5f7;
        border-radius: 12px;
        margin-bottom: 0.75rem;
        transition: all 0.3s ease;
    }
    .attachment-item:hover {
        background-color: #e8e8ed;
    }
    .attachment-info {
        flex: 1;
    }
    .attachment-name {
        font-weight: 600;
        color: #1d1d1f;
        margin-bottom: 0.25rem;
        font-size: 0.9375rem;
    }
    .attachment-meta {
        font-size: 0.8125rem;
        color: #86868b;
    }
    .attachment-download {
        padding: 0.625rem 1.25rem;
        background-color: #0071e3;
        color: white;
        text-decoration: none;
        border-radius: 20px;
        font-size: 0.875rem;
        transition: all 0.3s ease;
    }
    .attachment-download:hover {
        background-color: #0077ed;
        transform: translateY(-1px);
        box-shadow: 0 4px 12px rgba(0, 113, 227, 0.3);
    }
    .comments-section {
        margin-top: 4rem;
        padding-top: 2.5rem;
        border-top: 1px solid #f5f5f7;
    }
    .comments-title {
        font-size: 1.5rem;
        font-weight: 600;
        color: #1d1d1f;
        margin-bottom: 2rem;
        letter-spacing: -0.01em;
    }
    .comment-input-box {
        margin-bottom: 2.5rem;
        padding: 1.5rem;
        background-color: #f5f5f7;
        border-radius: 12px;
    }
    .comment-input-header {
        display: flex;
        gap: 0.75rem;
        margin-bottom: 1rem;
    }
    .comment-avatar {
        width: 40px;
        height: 40px;
        min-width: 40px;
        min-height: 40px;
        max-width: 40px;
        max-height: 40px;
        border-radius: 50%;
        object-fit: cover;
        border: 1px solid #d2d2d7;
        flex-shrink: 0;
        overflow: hidden;
    }
    .comment-avatar-placeholder {
        width: 40px;
        height: 40px;
        min-width: 40px;
        min-height: 40px;
        max-width: 40px;
        max-height: 40px;
        border-radius: 50%;
        background-color: #d2d2d7;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1.2rem;
        color: #86868b;
        flex-shrink: 0;
        overflow: hidden;
    }
    .comment-input textarea {
        width: 100%;
        padding: 0.875rem;
        border: 1px solid #d2d2d7;
        border-radius: 8px;
        resize: vertical;
        font-family: inherit;
        font-size: 0.9375rem;
        transition: all 0.3s ease;
        outline: none;
    }
    .comment-input textarea:focus {
        border-color: #0071e3;
        box-shadow: 0 0 0 4px rgba(0, 113, 227, 0.1);
    }
    .comment-submit-btn {
        padding: 0.625rem 1.5rem;
        background-color: #0071e3;
        color: white;
        border: none;
        border-radius: 20px;
        cursor: pointer;
        font-size: 0.875rem;
        margin-top: 0.75rem;
        transition: all 0.3s ease;
    }
    .comment-submit-btn:hover {
        background-color: #0077ed;
        transform: translateY(-1px);
        box-shadow: 0 4px 12px rgba(0, 113, 227, 0.3);
    }
    .empty-comments {
        text-align: center;
        color: #86868b;
        padding: 3rem 2rem;
        font-size: 1rem;
    }
</style>
<div class="container">
    <div class="content">
        <article>
            <h1 class="article-title">${requestScope.blog.title}</h1>
            
            <div class="article-meta">
                <div class="article-author">
                    <c:choose>
                        <c:when test="${not empty requestScope.blog.author.avatar}">
                            <img src="${pageContext.request.contextPath}/${requestScope.blog.author.avatar}" 
                                 alt="头像" 
                                 class="article-avatar">
                        </c:when>
                        <c:otherwise>
                            <div class="article-avatar-placeholder">
                                👤
                            </div>
                        </c:otherwise>
                    </c:choose>
                    <div class="article-author-name">
                        <a href="${pageContext.request.contextPath}/space/${requestScope.blog.userId}">${requestScope.blog.author.nickname}</a>
                    </div>
                </div>
                <div class="article-info">
                    <span>浏览量: ${requestScope.blog.views}</span>
                    <c:if test="${not empty requestScope.formattedPublishTime}">
                        <span>发布时间: ${requestScope.formattedPublishTime}</span>
                    </c:if>
                    <c:if test="${not empty requestScope.formattedUpdateTime}">
                        <span>更新时间: ${requestScope.formattedUpdateTime}</span>
                    </c:if>
                </div>
                <c:if test="${not empty requestScope.blog.tags}">
                    <div class="article-tags">
                        <c:forEach var="tag" items="${requestScope.blog.tags}">
                            <a href="${pageContext.request.contextPath}/search?tagId=${tag.id}">#${tag.name}</a>
                        </c:forEach>
                    </div>
                </c:if>
                <c:if test="${sessionScope.user != null}">
                    <button onclick="toggleFavorite(${requestScope.blog.id}, ${requestScope.blog.isFavorited != null && requestScope.blog.isFavorited})" 
                            class="article-favorite-btn ${requestScope.blog.isFavorited != null && requestScope.blog.isFavorited ? 'active' : ''}">
                        <span class="favorite-icon">${requestScope.blog.isFavorited != null && requestScope.blog.isFavorited ? '♥' : '♡'}</span>
                        <span>${requestScope.blog.isFavorited != null && requestScope.blog.isFavorited ? '已收藏' : '收藏'}</span>
                    </button>
                </c:if>
            </div>

            <c:if test="${requestScope.blog.coverImage != null}">
                <div class="article-cover">
                    <img src="${requestScope.blog.coverImage}" alt="封面">
                </div>
            </c:if>

            <div class="markdown-content">
                <c:out value="${requestScope.blog.content}" escapeXml="false"/>
            </div>

            <!-- 附件列表 -->
            <c:if test="${not empty requestScope.attachments}">
                <div class="attachments-section">
                    <h3 class="attachments-title">附件</h3>
                    <div>
                        <c:forEach var="attachment" items="${requestScope.attachments}">
                            <div class="attachment-item">
                                <div class="attachment-info">
                                    <div class="attachment-name">
                                        ${attachment.fileName}
                                    </div>
                                    <div class="attachment-meta">
                                        ${attachment.formattedFileSize}
                                        <c:if test="${not empty attachment.uploadTime}">
                                            · ${attachment.uploadTime.toString().replace('T', ' ').substring(0, 16)}
                                        </c:if>
                                    </div>
                                </div>
                                <a href="${pageContext.request.contextPath}/${attachment.filePath}" 
                                   download="${attachment.fileName}"
                                   class="attachment-download">
                                    下载
                                </a>
                            </div>
                        </c:forEach>
                    </div>
                </div>
            </c:if>
        </article>

        <!-- 评论区 -->
        <c:if test="${requestScope.blog.status == 1}">
            <div class="comments-section">
                <h3 class="comments-title">评论</h3>
                
                <!-- 评论输入框 -->
                <c:if test="${sessionScope.user != null}">
                    <div class="comment-input-box">
                        <div class="comment-input-header">
                            <c:choose>
                                <c:when test="${not empty sessionScope.user.avatar}">
                                    <img src="${pageContext.request.contextPath}/${sessionScope.user.avatar}" 
                                         alt="头像" 
                                         class="comment-avatar">
                                </c:when>
                                <c:otherwise>
                                    <div class="comment-avatar-placeholder">
                                        👤
                                    </div>
                                </c:otherwise>
                            </c:choose>
                            <div class="comment-input" style="flex: 1;">
                                <textarea id="commentContent" 
                                          placeholder="写下你的评论..." 
                                          rows="3"></textarea>
                                <div style="display: flex; justify-content: flex-end;">
                                    <button onclick="submitComment(${requestScope.blog.id}, null)" 
                                            class="comment-submit-btn">
                                        发表评论
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:if>

                <!-- 评论列表 -->
                <div id="commentsList">
                    <c:choose>
                        <c:when test="${empty requestScope.comments}">
                            <p class="empty-comments">暂无评论，快来发表第一条评论吧！</p>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="comment" items="${requestScope.comments}">
                                <c:set var="comment" value="${comment}" scope="request"/>
                                <jsp:include page="comment-item.jsp"/>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </c:if>
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

// 评论相关函数
function submitComment(blogId, parentId) {
    const contentId = parentId ? 'replyContent-' + parentId : 'commentContent';
    const content = document.getElementById(contentId).value.trim();
    
    if (!content) {
        alert('评论内容不能为空');
        return;
    }
    
    const formData = new URLSearchParams();
    formData.append('action', 'add');
    formData.append('blogId', blogId);
    formData.append('content', content);
    if (parentId) {
        formData.append('parentId', parentId);
    }
    
    fetch('${pageContext.request.contextPath}/comment', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: formData
    }).then(response => response.json())
      .then(data => {
          if (data.success) {
              location.reload();
          } else {
              alert(data.message || '评论失败');
          }
      })
      .catch(error => {
          console.error('Error:', error);
          alert('评论失败，请重试');
      });
}

function showReplyForm(commentId, nickname) {
    const replyForm = document.getElementById('replyForm-' + commentId);
    if (replyForm) {
        replyForm.style.display = 'block';
        const textarea = document.getElementById('replyContent-' + commentId);
        if (textarea) {
            textarea.focus();
        }
    }
}

function hideReplyForm(commentId) {
    const replyForm = document.getElementById('replyForm-' + commentId);
    if (replyForm) {
        replyForm.style.display = 'none';
        const textarea = document.getElementById('replyContent-' + commentId);
        if (textarea) {
            textarea.value = '';
        }
    }
}

function deleteComment(commentId) {
    if (!confirm('确定要删除这条评论吗？')) {
        return;
    }
    
    const formData = new URLSearchParams();
    formData.append('action', 'delete');
    formData.append('commentId', commentId);
    
    fetch('${pageContext.request.contextPath}/comment', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: formData
    }).then(response => response.json())
      .then(data => {
          if (data.success) {
              location.reload();
          } else {
              alert(data.message || '删除失败');
          }
      })
      .catch(error => {
          console.error('Error:', error);
          alert('删除失败，请重试');
      });
}
</script>

<style>
article img {
    max-width: 100%;
    height: auto;
    border-radius: 4px;
    margin: 1rem 0;
}

article h1, article h2, article h3, article h4, article h5, article h6 {
    margin-top: 1.5rem;
    margin-bottom: 1rem;
}

article p {
    margin-bottom: 1rem;
}

article code {
    background-color: #f4f4f4;
    padding: 0.2rem 0.4rem;
    border-radius: 3px;
    font-family: 'Consolas', 'Monaco', 'Courier New', monospace;
    font-size: 0.9em;
}

article pre {
    background-color: #f4f4f4;
    padding: 1rem;
    border-radius: 4px;
    overflow-x: auto;
    border: 1px solid #ddd;
}

article pre code {
    background-color: transparent;
    padding: 0;
    border-radius: 0;
}

article blockquote {
    border-left: 4px solid #3498db;
    padding-left: 1rem;
    margin-left: 0;
    color: #777;
    margin-top: 1rem;
    margin-bottom: 1rem;
}

article ul, article ol {
    margin-bottom: 1rem;
    padding-left: 2rem;
}

article li {
    margin-bottom: 0.5rem;
}

article table {
    width: 100%;
    border-collapse: collapse;
    margin: 1rem 0;
}

article table th,
article table td {
    border: 1px solid #ddd;
    padding: 0.5rem;
    text-align: left;
}

article table th {
    background-color: #f4f4f4;
    font-weight: bold;
}

article hr {
    border: none;
    border-top: 2px solid #eee;
    margin: 2rem 0;
}

article a {
    color: #3498db;
    text-decoration: none;
}

article a:hover {
    text-decoration: underline;
}

article img {
    max-width: 100%;
    height: auto;
    border-radius: 4px;
    margin: 1rem 0;
}

.markdown-content {
    word-wrap: break-word;
}
</style>
<%@ include file="../common/footer.jsp" %>

