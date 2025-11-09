package cyou.mayloves.filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;

import java.io.IOException;

/**
 * 编码过滤器
 */
@WebFilter("/*")
public class EncodingFilter implements Filter {
    private static final String DEFAULT_ENCODING = "UTF-8";

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // 初始化
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        request.setCharacterEncoding(DEFAULT_ENCODING);
        response.setCharacterEncoding(DEFAULT_ENCODING);
        if (!response.isCommitted() && response.getContentType() == null) {
            response.setContentType("text/html;charset=" + DEFAULT_ENCODING);
        }
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        // 清理
    }
}

