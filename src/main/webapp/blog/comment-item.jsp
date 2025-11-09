<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="comment" value="${requestScope.comment}" />
<style>
    .comment-item {
        margin-bottom: 1.5rem;
        padding: 1.5rem;
        background-color: #f5f5f7;
        border-radius: 12px;
        transition: all 0.3s ease;
    }
    .comment-item:hover {
        background-color: #e8e8ed;
    }
    .comment-header {
        display: flex;
        gap: 0.75rem;
        margin-bottom: 0.75rem;
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
    .comment-body {
        flex: 1;
        min-width: 0;
    }
    .comment-author {
        font-weight: 600;
        color: #1d1d1f;
        margin-right: 0.5rem;
        font-size: 0.9375rem;
    }
    .comment-reply-to {
        color: #86868b;
        font-size: 0.875rem;
    }
    .comment-reply-target {
        color: #0071e3;
        font-size: 0.875rem;
        margin: 0 0.25rem;
    }
    .comment-time {
        color: #86868b;
        font-size: 0.8125rem;
        margin-left: 0.5rem;
    }
    .comment-content {
        color: #1d1d1f;
        line-height: 1.6;
        margin-bottom: 0.75rem;
        white-space: pre-wrap;
        word-wrap: break-word;
        font-size: 0.9375rem;
    }
    .comment-actions {
        display: flex;
        gap: 1rem;
        align-items: center;
    }
    .comment-action-btn {
        background: none;
        border: none;
        color: #0071e3;
        cursor: pointer;
        font-size: 0.875rem;
        padding: 0;
        transition: opacity 0.3s ease;
    }
    .comment-action-btn:hover {
        opacity: 0.7;
    }
    .comment-action-btn.danger {
        color: #ff3b30;
    }
    .reply-form {
        display: none;
        margin-top: 1.25rem;
        padding: 1.25rem;
        background-color: #ffffff;
        border-radius: 12px;
    }
    .reply-form textarea {
        width: 100%;
        padding: 0.75rem;
        border: 1px solid #d2d2d7;
        border-radius: 8px;
        resize: vertical;
        font-family: inherit;
        font-size: 0.9375rem;
        transition: all 0.3s ease;
        outline: none;
    }
    .reply-form textarea:focus {
        border-color: #0071e3;
        box-shadow: 0 0 0 4px rgba(0, 113, 227, 0.1);
    }
    .reply-actions {
        display: flex;
        justify-content: flex-end;
        gap: 0.75rem;
        margin-top: 0.75rem;
    }
    .reply-btn {
        padding: 0.5rem 1.25rem;
        border: none;
        border-radius: 20px;
        cursor: pointer;
        font-size: 0.875rem;
        transition: all 0.3s ease;
    }
    .reply-btn-secondary {
        background-color: #f5f5f7;
        color: #1d1d1f;
    }
    .reply-btn-secondary:hover {
        background-color: #e8e8ed;
    }
    .reply-btn-primary {
        background-color: #0071e3;
        color: white;
    }
    .reply-btn-primary:hover {
        background-color: #0077ed;
    }
    .comment-replies {
        margin-top: 1.25rem;
        padding-left: 1.5rem;
        border-left: 2px solid #d2d2d7;
    }
</style>
<div class="comment-item" data-comment-id="${comment.id}">
    <div class="comment-header">
        <!-- 用户头像 -->
        <c:choose>
            <c:when test="${not empty comment.user.avatar}">
                <img src="${pageContext.request.contextPath}/${comment.user.avatar}" 
                     alt="头像" 
                     class="comment-avatar">
            </c:when>
            <c:otherwise>
                <div class="comment-avatar-placeholder">
                    👤
                </div>
            </c:otherwise>
        </c:choose>
        
        <!-- 评论内容 -->
        <div class="comment-body">
            <div style="margin-bottom: 0.5rem;">
                <span class="comment-author">${comment.user.nickname}</span>
                <c:if test="${comment.parentUser != null}">
                    <span class="comment-reply-to">回复</span>
                    <span class="comment-reply-target">@${comment.parentUser.nickname}</span>
                </c:if>
                <span class="comment-time">${comment.createTime.toString().replace('T', ' ').substring(0, 16)}</span>
            </div>
            <div class="comment-content">${comment.content}</div>
            <div class="comment-actions">
                <button onclick="showReplyForm(${comment.id}, '${comment.user.nickname}')" class="comment-action-btn">回复</button>
                <c:if test="${sessionScope.user != null && sessionScope.user.id == comment.userId}">
                    <button onclick="deleteComment(${comment.id})" class="comment-action-btn danger">删除</button>
                </c:if>
            </div>
            
            <!-- 回复输入框（隐藏） -->
            <div id="replyForm-${comment.id}" class="reply-form">
                <div style="display: flex; gap: 0.75rem;">
                    <c:choose>
                        <c:when test="${not empty sessionScope.user.avatar}">
                            <img src="${pageContext.request.contextPath}/${sessionScope.user.avatar}" 
                                 alt="头像" 
                                 class="comment-avatar" 
                                 style="width: 32px; height: 32px; min-width: 32px; min-height: 32px; max-width: 32px; max-height: 32px;">
                        </c:when>
                        <c:otherwise>
                            <div class="comment-avatar-placeholder" 
                                 style="width: 32px; height: 32px; min-width: 32px; min-height: 32px; max-width: 32px; max-height: 32px; font-size: 1rem;">
                                👤
                            </div>
                        </c:otherwise>
                    </c:choose>
                    <div style="flex: 1;">
                        <textarea id="replyContent-${comment.id}" 
                                  placeholder="回复 ${comment.user.nickname}..." 
                                  rows="2"></textarea>
                        <div class="reply-actions">
                            <button onclick="hideReplyForm(${comment.id})" class="reply-btn reply-btn-secondary">
                                取消
                            </button>
                            <button onclick="submitComment(${requestScope.blog.id}, ${comment.id})" class="reply-btn reply-btn-primary">
                                发表回复
                            </button>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- 子评论列表 -->
            <c:if test="${not empty comment.replies}">
                <div class="comment-replies">
                    <c:forEach var="reply" items="${comment.replies}">
                        <c:set var="comment" value="${reply}" scope="request"/>
                        <jsp:include page="comment-item.jsp"/>
                    </c:forEach>
                </div>
            </c:if>
        </div>
    </div>
</div>

