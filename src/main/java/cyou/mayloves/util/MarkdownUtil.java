package cyou.mayloves.util;

import com.vladsch.flexmark.html.HtmlRenderer;
import com.vladsch.flexmark.parser.Parser;
import com.vladsch.flexmark.profile.pegdown.Extensions;
import com.vladsch.flexmark.profile.pegdown.PegdownOptionsAdapter;
import com.vladsch.flexmark.util.data.DataHolder;

/**
 * Markdown 工具类
 */
public class MarkdownUtil {
    private static final DataHolder OPTIONS = PegdownOptionsAdapter.flexmarkOptions(
            Extensions.ALL - Extensions.ANCHORLINKS  // 启用所有扩展，但禁用自动锚点链接
    );
    private static final Parser PARSER = Parser.builder(OPTIONS).build();
    private static final HtmlRenderer RENDERER = HtmlRenderer.builder(OPTIONS).build();

    /**
     * 将 Markdown 转换为 HTML
     *
     * @param markdown Markdown格式的文本
     * @return 转换后的HTML字符串
     */
    public static String markdownToHtml(String markdown) {
        if (markdown == null || markdown.trim().isEmpty()) {
            return "";
        }
        return RENDERER.render(PARSER.parse(markdown));
    }

    /**
     * 将 Markdown 转换为纯文本
     *
     * @param markdown Markdown格式的文本
     * @return 转换后的纯文本字符串
     */
    public static String markdownToPlainText(String markdown) {
        if (markdown == null || markdown.trim().isEmpty()) {
            return "";
        }

        // 先将Markdown转换为HTML
        String html = markdownToHtml(markdown);

        // 从HTML中提取纯文本
        // 去除所有HTML标签
        String plainText = html.replaceAll("<[^>]+>", "");

        // 解码HTML实体
        plainText = plainText.replace("&nbsp;", " ")
                .replace("&amp;", "&")
                .replace("&lt;", "<")
                .replace("&gt;", ">")
                .replace("&quot;", "\"")
                .replace("&#39;", "'");

        // 去除多余的空格和换行
        plainText = plainText.replaceAll("\\s+", " ").trim();

        return plainText;
    }
}

