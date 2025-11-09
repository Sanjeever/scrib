<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ include file="common/header.jsp" %>
<style>
    .page-title {
        font-size: 2.5rem;
        font-weight: 600;
        color: #1d1d1f;
        margin-bottom: 2.5rem;
        letter-spacing: -0.02em;
        /* text-align: center; */
    }
    .profile-content-wrapper {
        max-width: 600px;
        margin: 0 auto;
    }
    .profile-type-selector {
        margin-bottom: 2.5rem;
        text-align: center;
        padding-bottom: 1.5rem;
        border-bottom: 1px solid #f5f5f7;
    }
    .profile-type-select {
        padding: 0.625rem 1.25rem;
        border: 1px solid #d2d2d7;
        border-radius: 12px;
        font-size: 0.9375rem;
        font-family: inherit;
        background-color: #f5f5f7;
        cursor: pointer;
        transition: all 0.3s ease;
        outline: none;
    }
    .profile-type-select:focus {
        background-color: #ffffff;
        border-color: #0071e3;
        box-shadow: 0 0 0 4px rgba(0, 113, 227, 0.1);
    }
    .form-group {
        margin-bottom: 1.5rem;
    }
    .form-label {
        display: block;
        margin-bottom: 0.625rem;
        font-size: 0.875rem;
        font-weight: 500;
        color: #1d1d1f;
    }
    .form-input {
        width: 100%;
        padding: 0.875rem 1.25rem;
        border: 1px solid #d2d2d7;
        border-radius: 12px;
        font-size: 0.9375rem;
        font-family: inherit;
        background-color: #f5f5f7;
        transition: all 0.3s ease;
        outline: none;
    }
    .form-input:focus {
        background-color: #ffffff;
        border-color: #0071e3;
        box-shadow: 0 0 0 4px rgba(0, 113, 227, 0.1);
    }
    .form-textarea {
        width: 100%;
        padding: 0.875rem 1.25rem;
        border: 1px solid #d2d2d7;
        border-radius: 12px;
        font-size: 0.9375rem;
        font-family: inherit;
        background-color: #f5f5f7;
        resize: vertical;
        transition: all 0.3s ease;
        outline: none;
    }
    .form-textarea:focus {
        background-color: #ffffff;
        border-color: #0071e3;
        box-shadow: 0 0 0 4px rgba(0, 113, 227, 0.1);
    }
    .avatar-preview {
        text-align: center;
        margin-bottom: 2rem;
        padding: 1.5rem;
        background-color: #f5f5f7;
        border-radius: 12px;
    }
    .avatar-preview img {
        width: 120px;
        height: 120px;
        min-width: 120px;
        min-height: 120px;
        max-width: 120px;
        max-height: 120px;
        border-radius: 50%;
        object-fit: cover;
        border: 2px solid #d2d2d7;
        margin-bottom: 0.75rem;
        overflow: hidden;
    }
    .avatar-placeholder {
        width: 120px;
        height: 120px;
        min-width: 120px;
        min-height: 120px;
        max-width: 120px;
        max-height: 120px;
        border-radius: 50%;
        background-color: #d2d2d7;
        margin: 0 auto 0.75rem;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 3rem;
        color: #86868b;
        overflow: hidden;
    }
    .form-hint {
        color: #86868b;
        display: block;
        margin-top: 0.375rem;
        font-size: 0.8125rem;
    }
    .form-actions {
        display: flex;
        gap: 1rem;
        margin-top: 2.5rem;
        padding-top: 2rem;
        border-top: 1px solid #f5f5f7;
    }
    .form-actions .btn {
        flex: 1;
    }
    .form-section {
        margin-bottom: 2rem;
    }
    @media (max-width: 768px) {
        .profile-content-wrapper {
            max-width: 100%;
        }
        .page-title {
            font-size: 2rem;
            margin-bottom: 2rem;
        }
    }
    .alert {
        padding: 1rem 1.25rem;
        border-radius: 12px;
        margin-bottom: 1.5rem;
        font-size: 0.875rem;
    }
    .alert-error {
        background-color: #ffebee;
        color: #c62828;
        border: 1px solid #ffcdd2;
    }
    .alert-success {
        background-color: #e8f5e9;
        color: #2e7d32;
        border: 1px solid #c8e6c9;
    }
</style>
<div class="container">
    <div class="content">
        <h1 class="page-title">个人信息</h1>
        
        <div class="profile-content-wrapper">
            <!-- 下拉框选择 -->
            <div class="profile-type-selector">
                <select id="profileType" onchange="switchProfileType()" class="profile-type-select">
                    <option value="profile" ${(param.type == null || param.type == 'profile') && requestScope.type != 'password' ? 'selected' : ''}>资料维护</option>
                    <option value="password" ${param.type == 'password' || requestScope.type == 'password' ? 'selected' : ''}>更改密码</option>
                </select>
            </div>
            
            <c:if test="${requestScope.error != null}">
                <div class="alert alert-error">
                    ${requestScope.error}
                </div>
            </c:if>
            <c:if test="${requestScope.success != null}">
                <div class="alert alert-success">
                    ${requestScope.success}
                </div>
            </c:if>
            
            <!-- 资料维护表单 -->
            <div id="profileForm" style="display: ${param.type == 'password' || requestScope.type == 'password' ? 'none' : 'block'};">
                <form action="${pageContext.request.contextPath}/profile" method="post" enctype="multipart/form-data">
                    <div class="form-section">
                        <div class="avatar-preview">
                            <label class="form-label" style="display: block; margin-bottom: 1rem; font-weight: 500;">当前头像</label>
                            <c:choose>
                                <c:when test="${not empty requestScope.user.avatar}">
                                    <img src="${pageContext.request.contextPath}/${requestScope.user.avatar}" alt="头像">
                                </c:when>
                                <c:otherwise>
                                    <div class="avatar-placeholder">👤</div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label">上传新头像</label>
                            <input type="file" name="avatar" accept="image/*" class="form-input">
                            <span class="form-hint">支持 JPG、PNG、GIF 格式，最大 5MB</span>
                        </div>
                    </div>
                    
                    <div class="form-section">
                        <div class="form-group">
                            <label class="form-label">昵称</label>
                            <input type="text" name="nickname" value="${requestScope.user.nickname}" required class="form-input">
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label">签名</label>
                            <textarea name="signature" rows="4" maxlength="500" class="form-textarea">${requestScope.user.signature != null ? requestScope.user.signature : ''}</textarea>
                            <span class="form-hint">最多500个字符</span>
                        </div>
                    </div>
                    
                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary">保存</button>
                        <a href="${pageContext.request.contextPath}/home" class="btn" style="background-color: #f5f5f7; color: #1d1d1f; text-decoration: none; text-align: center;">取消</a>
                    </div>
                </form>
            </div>
            
            <!-- 更改密码表单 -->
            <div id="passwordForm" style="display: ${param.type == 'password' || requestScope.type == 'password' ? 'block' : 'none'};">
                <form action="${pageContext.request.contextPath}/profile" method="post" id="changePasswordForm">
                    <input type="hidden" name="action" value="changePassword">
                    
                    <div class="form-section">
                        <div class="form-group">
                            <label class="form-label">当前密码</label>
                            <input type="password" name="oldPassword" required class="form-input">
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label">新密码</label>
                            <input type="password" name="newPassword" required minlength="6" class="form-input">
                            <span class="form-hint">密码长度至少6位</span>
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label">确认新密码</label>
                            <input type="password" name="confirmPassword" required minlength="6" class="form-input">
                        </div>
                    </div>
                    
                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary">更改密码</button>
                        <a href="${pageContext.request.contextPath}/home" class="btn" style="background-color: #f5f5f7; color: #1d1d1f; text-decoration: none; text-align: center;">取消</a>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<script>
function switchProfileType() {
    const select = document.getElementById('profileType');
    const profileForm = document.getElementById('profileForm');
    const passwordForm = document.getElementById('passwordForm');
    
    if (select.value === 'profile') {
        profileForm.style.display = 'block';
        passwordForm.style.display = 'none';
        // 更新URL参数
        window.history.replaceState({}, '', '${pageContext.request.contextPath}/profile?type=profile');
    } else {
        profileForm.style.display = 'none';
        passwordForm.style.display = 'block';
        // 更新URL参数
        window.history.replaceState({}, '', '${pageContext.request.contextPath}/profile?type=password');
    }
}
</script>

<%@ include file="common/footer.jsp" %>

