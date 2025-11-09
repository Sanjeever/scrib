package cyou.mayloves.filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * 登录验证过滤器
 */
@WebFilter({"/blog/*", "/favorite", "/upload"})
public class AuthFilter implements Filter {
    private static final String[] EXCLUDED_PATHS = {
            "/blog/detail"
    };

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // 初始化
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        String path = httpRequest.getRequestURI();
        String contextPath = httpRequest.getContextPath();
        String pathInfo = path.substring(contextPath.length());

        // 检查是否在排除路径中
        boolean excluded = false;
        for (String excludedPath : EXCLUDED_PATHS) {
            if (pathInfo.startsWith(excludedPath)) {
                excluded = true;
                break;
            }
        }

        if (!excluded) {
            HttpSession session = httpRequest.getSession(false);
            if (session == null || session.getAttribute("user") == null) {
                httpResponse.sendRedirect(contextPath + "/login");
                return;
            }
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        // 清理
    }
}

