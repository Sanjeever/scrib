<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ include file="common/header.jsp" %>
<style>
    .form-container {
        max-width: 420px;
        margin: 2rem auto;
    }
    .form-title {
        text-align: center;
        font-size: 2rem;
        font-weight: 600;
        color: #1d1d1f;
        margin-bottom: 2.5rem;
        letter-spacing: -0.02em;
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
    .form-submit {
        width: 100%;
        margin-top: 0.5rem;
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
    .form-footer {
        text-align: center;
        margin-top: 2rem;
        color: #86868b;
        font-size: 0.875rem;
    }
    .form-footer a {
        color: #0071e3;
        text-decoration: none;
        transition: opacity 0.3s ease;
    }
    .form-footer a:hover {
        opacity: 0.7;
    }
</style>
<div class="container">
    <div class="content form-container">
        <h2 class="form-title">注册</h2>
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
        <form action="${pageContext.request.contextPath}/register" method="post">
            <div class="form-group">
                <label class="form-label">用户名</label>
                <input type="text" name="username" required class="form-input">
            </div>
            <div class="form-group">
                <label class="form-label">密码</label>
                <input type="password" name="password" required minlength="6" class="form-input">
            </div>
            <div class="form-group">
                <label class="form-label">确认密码</label>
                <input type="password" name="confirmPassword" required minlength="6" class="form-input">
            </div>
            <div class="form-group">
                <label class="form-label">昵称</label>
                <input type="text" name="nickname" class="form-input">
            </div>
            <button type="submit" class="btn btn-primary form-submit">注册</button>
        </form>
        <p class="form-footer">
            已有账号？<a href="${pageContext.request.contextPath}/login">立即登录</a>
        </p>
    </div>
</div>
<%@ include file="common/footer.jsp" %>

