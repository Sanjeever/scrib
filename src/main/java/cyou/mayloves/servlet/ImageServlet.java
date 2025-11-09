package cyou.mayloves.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;

/**
 * 图片访问 Servlet
 */
@WebServlet("/uploads/*")
public class ImageServlet extends HttpServlet {
    private static final String UPLOAD_DIR = "uploads";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // 获取请求的图片路径
        String pathInfo = request.getPathInfo();
        if (pathInfo == null || pathInfo.isEmpty() || pathInfo.equals("/")) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "图片路径不能为空");
            return;
        }

        // 移除开头的斜杠
        String imagePath = pathInfo.substring(1);

        // 防止路径遍历攻击
        if (imagePath.contains("..") || imagePath.contains("\\")) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "非法的路径");
            return;
        }

        // 构建完整的文件路径
        String realPath = getServletContext().getRealPath("/");
        File imageFile = new File(realPath, UPLOAD_DIR + File.separator + imagePath.replace("/", File.separator));

        // 检查文件是否存在
        if (!imageFile.exists() || !imageFile.isFile()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "图片不存在");
            return;
        }

        // 检查文件是否在 uploads 目录下
        File uploadDir = new File(realPath, UPLOAD_DIR);
        if (!imageFile.getCanonicalPath().startsWith(uploadDir.getCanonicalPath())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "非法的路径");
            return;
        }

        // 设置响应头
        String fileName = imageFile.getName();
        String contentType = getServletContext().getMimeType(fileName);
        if (contentType == null) {
            contentType = "image/jpeg"; // 默认类型
        }
        response.setContentType(contentType);
        response.setContentLengthLong(imageFile.length());
        response.setHeader("Cache-Control", "public, max-age=31536000");

        // 输出文件内容
        try (FileInputStream fis = new FileInputStream(imageFile);
             OutputStream os = response.getOutputStream()) {
            byte[] buffer = new byte[8192];
            int bytesRead;
            while ((bytesRead = fis.read(buffer)) != -1) {
                os.write(buffer, 0, bytesRead);
            }
        }
    }
}

