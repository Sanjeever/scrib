<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    cyou.mayloves.model.User user = (cyou.mayloves.model.User) session.getAttribute("user");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Scrib - ${param.title != null ? param.title : '博客系统'}</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: -apple-system, BlinkMacSystemFont, "SF Pro Display", "SF Pro Text", "Helvetica Neue", Arial, sans-serif;
            line-height: 1.6;
            color: #1d1d1f;
            background-color: #fbfbfd;
            -webkit-font-smoothing: antialiased;
            -moz-osx-font-smoothing: grayscale;
        }
        .header {
            background-color: rgba(255, 255, 255, 0.8);
            backdrop-filter: saturate(180%) blur(20px);
            -webkit-backdrop-filter: saturate(180%) blur(20px);
            box-shadow: 0 1px 0 rgba(0, 0, 0, 0.05);
            padding: 0.75rem 0;
            margin-bottom: 3rem;
            position: sticky;
            top: 0;
            z-index: 1000;
        }
        .container {
            max-width: 980px;
            margin: 0 auto;
            padding: 0 22px;
        }
        .nav {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .logo {
            font-size: 1.25rem;
            font-weight: 600;
            color: #1d1d1f;
            text-decoration: none;
            letter-spacing: -0.01em;
            transition: opacity 0.3s ease;
        }
        .logo:hover {
            opacity: 0.7;
        }
        .nav-links {
            display: flex;
            gap: 2rem;
            align-items: center;
            font-size: 0.875rem;
        }
        .nav-links a {
            color: #1d1d1f;
            text-decoration: none;
            transition: opacity 0.3s ease;
            font-weight: 400;
        }
        .nav-links a:hover {
            opacity: 0.6;
        }
        .nav-links span {
            color: #86868b;
            font-size: 0.875rem;
        }
        .btn {
            padding: 0.5rem 1.25rem;
            border: none;
            border-radius: 20px;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            font-size: 0.875rem;
            font-weight: 400;
            letter-spacing: -0.01em;
        }
        .btn-primary {
            background-color: #0071e3;
            color: white;
        }
        .btn-primary:hover {
            background-color: #0077ed;
            transform: translateY(-1px);
            box-shadow: 0 4px 12px rgba(0, 113, 227, 0.3);
        }
        .btn-primary:active {
            transform: translateY(0);
        }
        .btn-danger {
            background-color: #ff3b30;
            color: white;
        }
        .btn-danger:hover {
            background-color: #ff453a;
            transform: translateY(-1px);
            box-shadow: 0 4px 12px rgba(255, 59, 48, 0.3);
        }
        .btn-danger:active {
            transform: translateY(0);
        }
        .content {
            background-color: #ffffff;
            padding: 3rem;
            border-radius: 18px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
            margin-bottom: 3rem;
        }
        @media (max-width: 768px) {
            .container {
                padding: 0 16px;
            }
            .content {
                padding: 2rem 1.5rem;
            }
            .nav-links {
                gap: 1rem;
                font-size: 0.8125rem;
            }
        }
    </style>
</head>
<body>
<div class="header">
    <div class="container">
        <nav class="nav">
            <a href="${pageContext.request.contextPath}/home" class="logo">Scrib</a>
            <div class="nav-links">
                <!-- <a href="${pageContext.request.contextPath}/home">🔥 热门文章</a> -->
                <c:if test="${sessionScope.user != null}">
                    <a href="${pageContext.request.contextPath}/blog">我的博客</a>
                    <a href="${pageContext.request.contextPath}/favorite">我的收藏</a>
                    <a href="${pageContext.request.contextPath}/blog/new">新建博客</a>
                    <a href="${pageContext.request.contextPath}/profile">个人信息</a>
                    <span>👋 嗨, ${sessionScope.user.nickname}!</span>
                    <!-- <a href="${pageContext.request.contextPath}/logout" class="btn btn-danger">退出</a> -->
                    <a href="${pageContext.request.contextPath}/logout">退出</a>
                </c:if>
                <c:if test="${sessionScope.user == null}">
                    <!-- <a href="${pageContext.request.contextPath}/login" class="btn btn-primary">登录</a> -->
                    <a href="${pageContext.request.contextPath}/login">登录</a>
                    <a href="${pageContext.request.contextPath}/register">注册</a>
                </c:if>
            </div>
        </nav>
    </div>
</div>

