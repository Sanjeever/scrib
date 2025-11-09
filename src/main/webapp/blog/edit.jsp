<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ include file="../common/header.jsp" %>
<style>
    .page-title {
        font-size: 2.5rem;
        font-weight: 600;
        color: #1d1d1f;
        margin-bottom: 2.5rem;
        letter-spacing: -0.02em;
    }
</style>
<div class="container">
    <div class="content">
        <h2 class="page-title">${requestScope.blog != null ? '编辑博客' : '新建博客'}</h2>
        
        <c:if test="${requestScope.error != null}">
            <div style="background-color: #fee; color: #c33; padding: 1rem; border-radius: 4px; margin-bottom: 1rem;">
                ${requestScope.error}
            </div>
        </c:if>

        <form id="blogForm" action="${pageContext.request.contextPath}/blog" method="post">
            <input type="hidden" name="action" id="action" value="save">
            <c:if test="${requestScope.blog != null}">
                <input type="hidden" name="blogId" value="${requestScope.blog.id}">
            </c:if>

            <div style="margin-bottom: 1rem;">
                <label style="display: block; margin-bottom: 0.5rem; font-weight: bold;">标题:</label>
                <input type="text" name="title" id="title" required 
                       value="${requestScope.blog != null ? requestScope.blog.title : ''}"
                       style="width: 100%; padding: 0.75rem; border: 1px solid #ddd; border-radius: 4px;">
            </div>

            <div style="margin-bottom: 1rem;">
                <label style="display: block; margin-bottom: 0.5rem; font-weight: bold;">封面图片:</label>
                <div style="display: flex; gap: 1rem; align-items: center;">
                    <input type="text" name="coverImage" id="coverImage" 
                           value="${requestScope.blog != null ? requestScope.blog.coverImage : ''}"
                           placeholder="图片URL或上传图片"
                           style="flex: 1; padding: 0.75rem; border: 1px solid #ddd; border-radius: 4px;">
                    <button type="button" onclick="uploadImage('cover')" class="btn btn-primary">上传封面</button>
                </div>
                <div id="coverPreview" style="margin-top: 1rem;">
                    <c:if test="${requestScope.blog != null && requestScope.blog.coverImage != null}">
                        <img src="${requestScope.blog.coverImage}" alt="封面预览" 
                             style="max-width: 300px; max-height: 200px; border-radius: 4px;">
                    </c:if>
                </div>
            </div>

            <div style="margin-bottom: 1rem;">
                <label style="display: block; margin-bottom: 0.5rem; font-weight: bold;">标签 (用逗号分隔):</label>
                <%
                    String tagsValue = "";
                    if (request.getAttribute("blog") != null) {
                        cyou.mayloves.model.Blog blog = (cyou.mayloves.model.Blog) request.getAttribute("blog");
                        if (blog.getTags() != null && !blog.getTags().isEmpty()) {
                            java.util.List<String> tagNames = new java.util.ArrayList<>();
                            for (cyou.mayloves.model.Tag tag : blog.getTags()) {
                                tagNames.add(tag.getName());
                            }
                            tagsValue = String.join(",", tagNames);
                        }
                    }
                %>
                <input type="text" name="tags" 
                       value="<%= tagsValue %>"
                       placeholder="例如: Java,Spring,Web"
                       style="width: 100%; padding: 0.75rem; border: 1px solid #ddd; border-radius: 4px;">
            </div>

            <div style="margin-bottom: 1rem;">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 0.5rem;">
                    <label style="font-weight: bold;">内容 (Markdown格式):</label>
                    <div style="display: flex; gap: 0.5rem;">
                        <button type="button" onclick="insertImage()" class="btn btn-primary">插入图片</button>
                        <button type="button" onclick="togglePreviewMode()" id="previewToggleBtn" class="btn btn-primary">隐藏预览</button>
                        <button type="button" onclick="previewMarkdown()" class="btn btn-primary">新窗口预览</button>
                    </div>
                </div>
                <div id="editorContainer" style="display: flex; gap: 1rem; min-height: 500px;">
                    <div id="editorPanel" style="flex: 1; min-width: 0;">
                        <textarea name="content" id="content" rows="20" required 
                                  style="width: 100%; height: 500px; padding: 0.75rem; border: 1px solid #ddd; border-radius: 4px; font-family: monospace; resize: vertical;">${requestScope.blog != null ? requestScope.blog.content : ''}</textarea>
                    </div>
                    <div id="previewPanel" style="flex: 1; display: block; min-width: 0; border: 1px solid #ddd; border-radius: 4px; padding: 1rem; overflow-y: auto; background-color: #fafafa; height: 500px;">
                        <div id="livePreview" style="min-height: 100%;">
                            <div style="text-align: center; color: #777; padding: 2rem;">开始输入内容，实时预览将在这里显示...</div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 附件管理 -->
            <div style="margin-bottom: 2rem; padding: 1.5rem; background-color: #f9f9f9; border-radius: 8px; border: 1px solid #eee;">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1rem;">
                    <label style="font-weight: bold; font-size: 1.1rem;">附件管理</label>
                    <button type="button" onclick="uploadAttachment()" class="btn btn-primary" style="font-size: 0.9rem;">上传附件</button>
                </div>
                <div id="attachmentsList" style="display: flex; flex-direction: column; gap: 0.75rem;">
                    <c:if test="${requestScope.blog != null}">
                        <%
                            // 加载附件列表
                            if (request.getAttribute("blog") != null) {
                                cyou.mayloves.model.Blog blog = (cyou.mayloves.model.Blog) request.getAttribute("blog");
                                if (blog.getId() != null) {
                                    cyou.mayloves.dao.AttachmentDAO attachmentDAO = new cyou.mayloves.dao.AttachmentDAO();
                                    java.util.List<cyou.mayloves.model.Attachment> attachments = attachmentDAO.findByBlogId(blog.getId());
                                    request.setAttribute("editAttachments", attachments);
                                }
                            }
                        %>
                        <c:forEach var="attachment" items="${requestScope.editAttachments}">
                            <div class="attachment-item" data-id="${attachment.id}" data-file-name="<c:out value="${attachment.fileName}" escapeXml="true"/>" style="display: flex; align-items: center; padding: 0.75rem; background-color: white; border-radius: 4px; border: 1px solid #ddd;">
                                <div style="flex: 1;">
                                    <div style="font-weight: bold; color: #333; margin-bottom: 0.25rem;">
                                        ${attachment.fileName}
                                    </div>
                                    <div style="font-size: 0.85rem; color: #777;">
                                        ${attachment.formattedFileSize}
                                    </div>
                                </div>
                                <button type="button" onclick="deleteAttachmentFromElement(this)" 
                                        style="padding: 0.5rem 1rem; background-color: #e74c3c; color: white; border: none; border-radius: 4px; cursor: pointer; font-size: 0.85rem;">
                                    删除
                                </button>
                            </div>
                        </c:forEach>
                    </c:if>
                    <div id="newAttachmentsList"></div>
                </div>
            </div>

            <div style="display: flex; gap: 1rem;">
                <button type="button" onclick="saveDraft()" class="btn" style="background-color: #95a5a6; color: white;">保存草稿</button>
                <button type="button" onclick="publish()" class="btn btn-primary">发布</button>
            </div>
        </form>
    </div>
</div>

<style>
#editorContainer {
    position: relative;
}
#previewPanel {
    max-height: 500px;
}
#livePreview h1, #livePreview h2, #livePreview h3, #livePreview h4, #livePreview h5, #livePreview h6 {
    margin-top: 1.5rem;
    margin-bottom: 1rem;
}
#livePreview p {
    margin-bottom: 1rem;
}
#livePreview code {
    background-color: #f4f4f4;
    padding: 0.2rem 0.4rem;
    border-radius: 3px;
    font-family: 'Consolas', 'Monaco', 'Courier New', monospace;
    font-size: 0.9em;
}
#livePreview pre {
    background-color: #f4f4f4;
    padding: 1rem;
    border-radius: 4px;
    overflow-x: auto;
    border: 1px solid #ddd;
}
#livePreview pre code {
    background-color: transparent;
    padding: 0;
    border-radius: 0;
}
#livePreview blockquote {
    border-left: 4px solid #3498db;
    padding-left: 1rem;
    margin-left: 0;
    color: #777;
    margin-top: 1rem;
    margin-bottom: 1rem;
}
#livePreview ul, #livePreview ol {
    margin-bottom: 1rem;
    padding-left: 2rem;
}
#livePreview li {
    margin-bottom: 0.5rem;
}
#livePreview table {
    width: 100%;
    border-collapse: collapse;
    margin: 1rem 0;
}
#livePreview table th, #livePreview table td {
    border: 1px solid #ddd;
    padding: 0.5rem;
    text-align: left;
}
#livePreview table th {
    background-color: #f4f4f4;
    font-weight: bold;
}
#livePreview hr {
    border: none;
    border-top: 2px solid #eee;
    margin: 2rem 0;
}
#livePreview a {
    color: #3498db;
    text-decoration: none;
}
#livePreview a:hover {
    text-decoration: underline;
}
#livePreview img {
    max-width: 100%;
    height: auto;
    border-radius: 4px;
    margin: 1rem 0;
}
</style>

<script>
let previewMode = false; // false表示预览面板显示，true表示隐藏
let previewDebounceTimer = null;
let previewThrottleTimer = null;
let isUpdating = false; // 是否正在更新预览
let pendingUpdate = false; // 是否有待处理的更新
let lastContentHash = ''; // 上次更新的内容哈希，避免重复渲染
const PREVIEW_DEBOUNCE_DELAY = 800; // 防抖延迟800ms（增加到800ms，减少请求频率）
const PREVIEW_THROTTLE_DELAY = 300; // 节流延迟300ms（最快更新间隔）
const contextPath = '${pageContext.request.contextPath}';

// 切换预览模式（隐藏/显示预览面板）
function togglePreviewMode() {
    previewMode = !previewMode;
    const previewPanel = document.getElementById('previewPanel');
    const toggleBtn = document.getElementById('previewToggleBtn');
    
    if (previewMode) {
        previewPanel.style.display = 'none';
        toggleBtn.textContent = '显示预览';
    } else {
        previewPanel.style.display = 'block';
        toggleBtn.textContent = '隐藏预览';
        // 立即更新一次预览
        updateLivePreview();
    }
}

// 获取光标位置对应的文本
function getCursorContext(textarea) {
    const content = textarea.value;
    const cursorPos = textarea.selectionStart;
    const textBeforeCursor = content.substring(0, cursorPos);
    
    // 获取光标前的最近几行文本作为上下文（用于定位）
    const lines = textBeforeCursor.split('\n');
    const currentLine = lines.length - 1;
    const currentLineText = lines[currentLine] || '';
    
    // 计算滚动比例（基于光标位置）
    const scrollRatio = cursorPos / Math.max(content.length, 1);
    
    return {
        cursorPos: cursorPos,
        currentLine: currentLine,
        currentLineText: currentLineText,
        textBeforeCursor: textBeforeCursor,
        scrollRatio: scrollRatio,
        totalLines: content.split('\n').length
    };
}

// 在HTML中查找对应的位置并滚动（优化版本）
function scrollToPosition(livePreview, context) {
    if (!livePreview || !context) return;
    
    const previewPanel = document.getElementById('previewPanel');
    if (!previewPanel) return;
    
    // 使用 requestAnimationFrame 优化滚动性能
    requestAnimationFrame(() => {
        // 方法1: 尝试通过文本匹配找到位置（优化：只搜索可见元素）
        const searchText = context.currentLineText.trim();
        if (searchText && searchText.length > 3) {
            // 优先搜索标题元素（h1-h6），它们更容易定位
            const headings = livePreview.querySelectorAll('h1, h2, h3, h4, h5, h6, p, li');
            let bestMatch = null;
            
            for (let element of headings) {
                const text = element.textContent || '';
                if (text.includes(searchText)) {
                    bestMatch = element;
                    break; // 找到第一个匹配就停止
                }
            }
            
            if (bestMatch) {
                previewPanel.isScrolling = true;
                bestMatch.scrollIntoView({ behavior: 'instant', block: 'center' });
                setTimeout(() => {
                    previewPanel.isScrolling = false;
                }, 50);
                return;
            }
        }
        
        // 方法2: 使用滚动比例来估算位置（更快）
        previewPanel.isScrolling = true;
        const scrollHeight = previewPanel.scrollHeight - previewPanel.clientHeight;
        const targetScrollTop = Math.max(0, Math.min(scrollHeight, scrollHeight * context.scrollRatio));
        previewPanel.scrollTop = targetScrollTop;
        
        setTimeout(() => {
            previewPanel.isScrolling = false;
        }, 50);
    });
}

// 更新实时预览（优化版本）
function updateLivePreview() {
    const contentTextarea = document.getElementById('content');
    const content = contentTextarea.value;
    const livePreview = document.getElementById('livePreview');
    
    // 如果内容为空，显示提示
    if (!content || content.trim() === '') {
        livePreview.innerHTML = '<div style="text-align: center; color: #777; padding: 2rem;">开始输入内容，实时预览将在这里显示...</div>';
        lastContentHash = '';
        return;
    }
    
    // 计算内容哈希，避免重复渲染相同内容
    const contentHash = content.length + '_' + content.substring(0, 50).replace(/\s/g, '');
    if (contentHash === lastContentHash && livePreview.innerHTML.trim() !== '') {
        // 内容没有变化，不需要更新
        return;
    }
    
    // 如果正在更新，标记为待处理
    if (isUpdating) {
        pendingUpdate = true;
        return;
    }
    
    isUpdating = true;
    lastContentHash = contentHash;
    
    // 记录更新前的上下文信息
    const context = getCursorContext(contentTextarea);
    
    // 使用 requestAnimationFrame 优化DOM更新
    requestAnimationFrame(() => {
        // 显示加载状态（只在内容真正变化时显示）
        const currentHtml = livePreview.innerHTML;
        if (!currentHtml.includes('正在渲染') && !currentHtml.includes('预览失败')) {
            livePreview.innerHTML = '<div style="text-align: center; color: #777; padding: 2rem;">正在渲染...</div>';
        }
        
        // 调用后端API渲染Markdown
        const params = new URLSearchParams();
        params.append('action', 'preview');
        params.append('content', content);
        
        fetch(contextPath + '/blog', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
            },
            body: params.toString()
        })
        .then(response => {
            if (!response.ok) {
                throw new Error('预览失败: HTTP ' + response.status);
            }
            return response.text();
        })
        .then(html => {
            // 使用 requestAnimationFrame 优化DOM更新
            requestAnimationFrame(() => {
                // 修复预览HTML中的图片URL，确保它们可以正确加载
                // 将相对路径的图片URL转换为绝对路径
                const tempDiv = document.createElement('div');
                tempDiv.innerHTML = html;
                const images = tempDiv.querySelectorAll('img');
                images.forEach(img => {
                    const src = img.getAttribute('src');
                    if (src) {
                        // 跳过完整URL（http://, https://, //）
                        if (src.startsWith('http://') || src.startsWith('https://') || src.startsWith('//')) {
                            return;
                        }
                        
                        // 处理相对路径（以/开头）
                        if (src.startsWith('/')) {
                            // 如果URL包含/uploads/路径
                            if (src.includes('/uploads/')) {
                                // 如果URL以/uploads/开头，缺少contextPath，需要添加
                                // 例如：/uploads/content/xxx.jpg -> /scrib/uploads/content/xxx.jpg
                                if (src.startsWith('/uploads/')) {
                                    img.setAttribute('src', contextPath + src);
                                }
                                // 如果URL已经包含contextPath（如 /scrib/uploads/...），不需要修改
                                // 但为了确保正确，检查一下格式
                                else if (!src.startsWith(contextPath + '/uploads/')) {
                                    // 如果URL包含/uploads/但不是以contextPath开头，尝试修复
                                    const uploadsIndex = src.indexOf('/uploads/');
                                    if (uploadsIndex >= 0) {
                                        const uploadsPath = src.substring(uploadsIndex);
                                        img.setAttribute('src', contextPath + uploadsPath);
                                    }
                                }
                            }
                        }
                        // 处理相对路径（不以/开头）
                        else if (src.includes('/uploads/')) {
                            // 相对路径，需要添加contextPath和开头的/
                            const uploadsIndex = src.indexOf('/uploads/');
                            if (uploadsIndex >= 0) {
                                const uploadsPath = src.substring(uploadsIndex);
                                img.setAttribute('src', contextPath + '/' + uploadsPath);
                            }
                        }
                    }
                });
                livePreview.innerHTML = tempDiv.innerHTML;
                
                // 调试：检查图片URL是否正确
                console.log('Preview images:', Array.from(tempDiv.querySelectorAll('img')).map(img => img.getAttribute('src')));
                
                // 等待DOM更新后，滚动到对应位置
                requestAnimationFrame(() => {
                    scrollToPosition(livePreview, context);
                    
                    // 标记更新完成
                    isUpdating = false;
                    
                    // 如果有待处理的更新，继续处理
                    if (pendingUpdate) {
                        pendingUpdate = false;
                        setTimeout(updateLivePreview, 100);
                    }
                });
            });
        })
        .catch(error => {
            livePreview.innerHTML = '<div style="color: red; padding: 2rem;">预览失败: ' + error.message + '</div>';
            console.error('预览失败:', error);
            isUpdating = false;
            pendingUpdate = false;
        });
    });
}

// 防抖+节流更新预览（优化版本）
function debouncedUpdatePreview() {
    const previewPanel = document.getElementById('previewPanel');
    if (!previewPanel || previewPanel.style.display === 'none') {
        return;
    }
    
    // 清除防抖定时器
    clearTimeout(previewDebounceTimer);
    
    // 节流：如果距离上次更新太近，延迟更新
    const now = Date.now();
    if (previewThrottleTimer && (now - previewThrottleTimer) < PREVIEW_THROTTLE_DELAY) {
        // 设置防抖延迟
        previewDebounceTimer = setTimeout(() => {
            previewThrottleTimer = Date.now();
            updateLivePreview();
        }, PREVIEW_DEBOUNCE_DELAY);
        return;
    }
    
    // 设置防抖延迟
    previewDebounceTimer = setTimeout(() => {
        previewThrottleTimer = Date.now();
        updateLivePreview();
    }, PREVIEW_DEBOUNCE_DELAY);
}

// 监听编辑框输入事件和其他事件
document.addEventListener('DOMContentLoaded', function() {
    const contentTextarea = document.getElementById('content');
    if (contentTextarea) {
        // 输入事件
        contentTextarea.addEventListener('input', debouncedUpdatePreview);
        
        // 光标移动事件（实时更新预览位置）- 使用防抖优化
        let cursorUpdateTimer = null;
        contentTextarea.addEventListener('keyup', function(e) {
            // 方向键、Home、End等导航键
            if (e.key.startsWith('Arrow') || e.key === 'Home' || e.key === 'End' || 
                e.key === 'PageUp' || e.key === 'PageDown') {
                clearTimeout(cursorUpdateTimer);
                // 延迟更新，避免频繁操作
                cursorUpdateTimer = setTimeout(() => {
                    const previewPanel = document.getElementById('previewPanel');
                    if (previewPanel && previewPanel.style.display !== 'none') {
                        const context = getCursorContext(contentTextarea);
                        const livePreview = document.getElementById('livePreview');
                        scrollToPosition(livePreview, context);
                    }
                }, 200); // 200ms延迟
            }
        });
        
        // 鼠标点击事件（光标位置变化）- 使用防抖优化
        contentTextarea.addEventListener('click', function() {
            clearTimeout(cursorUpdateTimer);
            cursorUpdateTimer = setTimeout(() => {
                const previewPanel = document.getElementById('previewPanel');
                if (previewPanel && previewPanel.style.display !== 'none') {
                    const context = getCursorContext(contentTextarea);
                    const livePreview = document.getElementById('livePreview');
                    scrollToPosition(livePreview, context);
                }
            }, 200); // 200ms延迟
        });
        
        // 粘贴事件
        contentTextarea.addEventListener('paste', function() {
            // 粘贴后延迟一下再更新预览，确保内容已粘贴
            setTimeout(() => {
                const previewPanel = document.getElementById('previewPanel');
                if (previewPanel && previewPanel.style.display !== 'none') {
                    updateLivePreview();
                }
            }, 100);
        });
        
        // 滚动事件（同步滚动预览面板）- 大幅优化性能
        let scrollSyncTimer = null;
        let lastScrollTime = 0;
        let isScrolling = false;
        const SCROLL_THROTTLE = 200; // 滚动节流200ms（增加到200ms，减少更新频率）
        
        contentTextarea.addEventListener('scroll', function() {
            const now = Date.now();
            // 更严格的节流：如果正在滚动或距离上次更新太近，直接返回
            if (isScrolling || (now - lastScrollTime < SCROLL_THROTTLE)) {
                return;
            }
            
            isScrolling = true;
            lastScrollTime = now;
            
            // 清除之前的定时器
            clearTimeout(scrollSyncTimer);
            
            // 使用更长的延迟，减少更新频率
            scrollSyncTimer = setTimeout(() => {
                const previewPanel = document.getElementById('previewPanel');
                if (previewPanel && previewPanel.style.display !== 'none' && !previewPanel.isScrolling) {
                    // 使用 requestAnimationFrame 优化滚动性能
                    requestAnimationFrame(() => {
                        try {
                            const scrollHeight = contentTextarea.scrollHeight - contentTextarea.clientHeight;
                            if (scrollHeight > 0) {
                                const scrollRatio = contentTextarea.scrollTop / scrollHeight;
                                const previewScrollHeight = previewPanel.scrollHeight - previewPanel.clientHeight;
                                
                                // 只在有明显变化时才更新（避免微小变化导致的抖动）
                                const currentScrollTop = previewPanel.scrollTop;
                                const targetScrollTop = Math.max(0, Math.min(previewScrollHeight, previewScrollHeight * scrollRatio));
                                const scrollDiff = Math.abs(currentScrollTop - targetScrollTop);
                                
                                // 只有当滚动差异大于10px时才更新，减少不必要的滚动
                                if (scrollDiff > 10) {
                                    previewPanel.scrollTop = targetScrollTop;
                                }
                            }
                        } catch (e) {
                            // 忽略滚动错误
                        } finally {
                            isScrolling = false;
                        }
                    });
                } else {
                    isScrolling = false;
                }
            }, 150); // 增加到150ms延迟，进一步减少更新频率
        });
    }
    
    // 页面加载时更新一次预览
    setTimeout(() => {
        updateLivePreview();
    }, 300);
});

function uploadImage(type) {
    const input = document.createElement('input');
    input.type = 'file';
    input.accept = 'image/*';
    input.onchange = function(e) {
        const file = e.target.files[0];
        if (!file) return;
        
        const formData = new FormData();
        formData.append('file', file);
        formData.append('type', type);
        
        fetch('${pageContext.request.contextPath}/upload', {
            method: 'POST',
            body: formData
        })
        .then(response => response.json())
        .then(data => {
            if (data.url) {
                if (type === 'cover') {
                    document.getElementById('coverImage').value = data.url;
                    const preview = document.getElementById('coverPreview');
                    preview.innerHTML = '<img src="' + data.url + '" alt="封面预览" style="max-width: 300px; max-height: 200px; border-radius: 4px;">';
                } else {
                    insertImageUrl(data.url);
                }
            }
        });
    };
    input.click();
}

function insertImage() {
    uploadImage('content');
}

function insertImageUrl(url) {
    const textarea = document.getElementById('content');
    const start = textarea.selectionStart;
    const end = textarea.selectionEnd;
    const text = textarea.value;
    const imageMarkdown = '![图片](' + url + ')';
    textarea.value = text.substring(0, start) + imageMarkdown + text.substring(end);
    textarea.focus();
    textarea.setSelectionRange(start + imageMarkdown.length, start + imageMarkdown.length);
    
    // 立即触发预览更新，确保新插入的图片能显示
    const previewPanel = document.getElementById('previewPanel');
    if (previewPanel && previewPanel.style.display !== 'none') {
        // 延迟一下，确保textarea值已更新
        setTimeout(() => {
            updateLivePreview();
        }, 100);
    }
}

function saveDraft() {
    document.getElementById('action').value = 'save';
    document.getElementById('blogForm').submit();
}

function publish() {
    document.getElementById('action').value = 'publish';
    document.getElementById('blogForm').submit();
}

function uploadAttachment() {
    const blogId = document.querySelector('input[name="blogId"]');
    if (!blogId || !blogId.value) {
        alert('请先保存博客后再上传附件');
        return;
    }

    const input = document.createElement('input');
    input.type = 'file';
    input.onchange = function(e) {
        const file = e.target.files[0];
        if (!file) return;
        
        // 检查文件大小（50MB限制）
        if (file.size > 50 * 1024 * 1024) {
            alert('文件大小不能超过50MB');
            return;
        }
        
        const formData = new FormData();
        formData.append('file', file);
        formData.append('type', 'attachment');
        formData.append('blogId', blogId.value);
        
        // 显示上传进度
        const loadingDiv = document.createElement('div');
        loadingDiv.className = 'attachment-item';
        loadingDiv.style.display = 'flex';
        loadingDiv.style.alignItems = 'center';
        loadingDiv.style.padding = '0.75rem';
        loadingDiv.style.backgroundColor = '#fff3cd';
        loadingDiv.style.borderRadius = '4px';
        loadingDiv.style.border = '1px solid #ffc107';
        loadingDiv.innerHTML = '<div style="flex: 1;"><div style="font-weight: bold; color: #333;">' + file.name + '</div><div style="font-size: 0.85rem; color: #777;">上传中...</div></div>';
        document.getElementById('newAttachmentsList').appendChild(loadingDiv);
        
        fetch('${pageContext.request.contextPath}/upload', {
            method: 'POST',
            body: formData
        })
        .then(response => {
            if (!response.ok) {
                return response.text().then(text => {
                    throw new Error(text || '上传失败');
                });
            }
            return response.json();
        })
        .then(data => {
            if (data.success) {
                // 替换加载提示为实际附件项
                loadingDiv.style.backgroundColor = 'white';
                loadingDiv.style.borderColor = '#ddd';
                loadingDiv.innerHTML = '<div style="flex: 1;"><div style="font-weight: bold; color: #333;">' + data.fileName + '</div><div style="font-size: 0.85rem; color: #777;">' + formatFileSize(data.fileSize) + '</div></div><button type="button" onclick="deleteAttachment(' + data.id + ', \'' + data.fileName.replace(/'/g, "\\'") + '\')" style="padding: 0.5rem 1rem; background-color: #e74c3c; color: white; border: none; border-radius: 4px; cursor: pointer; font-size: 0.85rem;">删除</button>';
                loadingDiv.setAttribute('data-id', data.id);
                loadingDiv.className = 'attachment-item';
            } else {
                throw new Error('上传失败');
            }
        })
        .catch(error => {
            alert('上传失败: ' + error.message);
            loadingDiv.remove();
        });
    };
    input.click();
}

function deleteAttachment(attachmentId, fileName) {
    if (!confirm('确定要删除附件 "' + fileName + '" 吗？')) {
        return;
    }
    
    fetch('${pageContext.request.contextPath}/attachment/delete', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'id=' + attachmentId
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            // 移除附件项
            const item = document.querySelector('.attachment-item[data-id="' + attachmentId + '"]');
            if (item) {
                item.remove();
            }
        } else {
            alert('删除失败: ' + (data.message || '未知错误'));
        }
    })
    .catch(error => {
        alert('删除失败: ' + error.message);
    });
}

function deleteAttachmentFromElement(button) {
    const item = button.closest('.attachment-item');
    const attachmentId = item.getAttribute('data-id');
    const fileName = item.getAttribute('data-file-name');
    deleteAttachment(attachmentId, fileName);
}

function formatFileSize(bytes) {
    if (bytes < 1024) {
        return bytes + ' B';
    } else if (bytes < 1024 * 1024) {
        return (bytes / 1024).toFixed(2) + ' KB';
    } else if (bytes < 1024 * 1024 * 1024) {
        return (bytes / (1024 * 1024)).toFixed(2) + ' MB';
    } else {
        return (bytes / (1024 * 1024 * 1024)).toFixed(2) + ' GB';
    }
}

function previewMarkdown() {
    const content = document.getElementById('content').value;
    const title = document.getElementById('title').value || '预览';
    
    // 显示加载提示
    const previewWindow = window.open('', '_blank');
    if (!previewWindow) {
        alert('无法打开预览窗口，请检查浏览器弹窗拦截设置');
        return;
    }
    
    const styles = `
        body { 
            padding: 2rem; 
            max-width: 800px; 
            margin: 0 auto; 
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            line-height: 1.6;
        }
        h1, h2, h3, h4, h5, h6 {
            margin-top: 1.5rem;
            margin-bottom: 1rem;
        }
        p { margin-bottom: 1rem; }
        code {
            background-color: #f4f4f4;
            padding: 0.2rem 0.4rem;
            border-radius: 3px;
            font-family: 'Consolas', 'Monaco', 'Courier New', monospace;
            font-size: 0.9em;
        }
        pre {
            background-color: #f4f4f4;
            padding: 1rem;
            border-radius: 4px;
            overflow-x: auto;
            border: 1px solid #ddd;
        }
        pre code {
            background-color: transparent;
            padding: 0;
            border-radius: 0;
        }
        blockquote {
            border-left: 4px solid #3498db;
            padding-left: 1rem;
            margin-left: 0;
            color: #777;
            margin-top: 1rem;
            margin-bottom: 1rem;
        }
        ul, ol {
            margin-bottom: 1rem;
            padding-left: 2rem;
        }
        li { margin-bottom: 0.5rem; }
        table {
            width: 100%;
            border-collapse: collapse;
            margin: 1rem 0;
        }
        table th, table td {
            border: 1px solid #ddd;
            padding: 0.5rem;
            text-align: left;
        }
        table th {
            background-color: #f4f4f4;
            font-weight: bold;
        }
        hr {
            border: none;
            border-top: 2px solid #eee;
            margin: 2rem 0;
        }
        a {
            color: #3498db;
            text-decoration: none;
        }
        a:hover {
            text-decoration: underline;
        }
        img {
            max-width: 100%;
            height: auto;
            border-radius: 4px;
            margin: 1rem 0;
        }
        .loading {
            text-align: center;
            padding: 2rem;
            color: #777;
        }
    `;
    
    previewWindow.document.write('<!DOCTYPE html><html><head><title>预览 - ' + title + '</title><meta charset="UTF-8"><style>' + styles + '</style></head><body><div class="loading">正在加载预览...</div></body></html>');
    previewWindow.document.close();
    
    // 调用后端API渲染Markdown
    // 使用 URLSearchParams 而不是 FormData，避免 multipart/form-data 解析问题
    const params = new URLSearchParams();
    params.append('action', 'preview');
    params.append('content', content);
    
    fetch('${pageContext.request.contextPath}' + '/blog', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
        },
        body: params.toString()
    })
    .then(response => {
        if (!response.ok) {
            throw new Error('预览失败: HTTP ' + response.status);
        }
        return response.text();
    })
    .then(html => {
        previewWindow.document.open();
        previewWindow.document.write('<!DOCTYPE html><html><head><title>预览 - ' + title + '</title><meta charset="UTF-8"><style>' + styles + '</style></head><body><h1>' + title + '</h1>' + html + '</body></html>');
        previewWindow.document.close();
    })
    .catch(error => {
        previewWindow.document.open();
        previewWindow.document.write('<!DOCTYPE html><html><head><title>预览错误</title><meta charset="UTF-8"><style>' + styles + '</style></head><body><div style="color: red; padding: 2rem;">预览失败: ' + error.message + '</div></body></html>');
        previewWindow.document.close();
        console.error('预览失败:', error);
    });
}
</script>
<%@ include file="../common/footer.jsp" %>

