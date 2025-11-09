package cyou.mayloves.listener;

import cyou.mayloves.util.DBUtil;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

import java.sql.Connection;
import java.sql.SQLException;

/**
 * 应用监听器
 */
@WebListener
public class AppListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        // 应用启动时初始化数据库连接
        try {
            Connection conn = DBUtil.getConnection();
            if (conn != null) {
                conn.close();
                System.out.println("数据库连接初始化成功");
            }
        } catch (SQLException e) {
            System.err.println("数据库连接初始化失败: " + e.getMessage());
            e.printStackTrace();
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        // 应用关闭时的清理工作
        System.out.println("应用关闭");
    }
}

