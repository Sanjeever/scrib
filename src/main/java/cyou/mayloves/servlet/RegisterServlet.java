package cyou.mayloves.servlet;

import cyou.mayloves.dao.UserDAO;
import cyou.mayloves.model.User;
import cyou.mayloves.util.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/**
 * 注册 Servlet
 */
@WebServlet("/register")
public class RegisterServlet extends HttpServlet {
    private UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String nickname = request.getParameter("nickname");

        // 验证输入
        if (username == null || username.trim().isEmpty()) {
            request.setAttribute("error", "用户名不能为空");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        if (password == null || password.trim().isEmpty() || password.length() < 6) {
            request.setAttribute("error", "密码长度至少6位");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        if (!password.equals(confirmPassword)) {
            request.setAttribute("error", "两次输入的密码不一致");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        // 检查用户名是否已存在
        if (userDAO.findByUsername(username.trim()) != null) {
            request.setAttribute("error", "用户名已存在");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        // 创建用户
        User user = new User();
        user.setUsername(username.trim());
        user.setPassword(PasswordUtil.md5(password));
        user.setNickname(nickname != null && !nickname.trim().isEmpty() ? nickname.trim() : username.trim());

        if (userDAO.create(user)) {
            request.setAttribute("success", "注册成功，请登录");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        } else {
            request.setAttribute("error", "注册失败，请重试");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
        }
    }
}

