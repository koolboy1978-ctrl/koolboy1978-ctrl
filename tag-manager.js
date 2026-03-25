// ==================== 标签管理系统 ====================

// 默认标签
const defaultTags = [
    { name: '山泉水吊水', selected: true },
    { name: '水库鱼来源', selected: true },
    { name: '吊水10-30天', selected: false },
    { name: '深圳中转仓', selected: false },
    { name: '两个吊水基地', selected: false },
    { name: '餐饮直供', selected: false },
    { name: '鱼生品质', selected: false }
];

// 从 localStorage 加载标签
function loadTags() {
    const saved = localStorage.getItem('geo_highlight_tags');
    if (saved) {
        try {
            return JSON.parse(saved);
        } catch (e) {
            console.error('解析标签失败:', e);
            return [...defaultTags];
        }
    }
    return [...defaultTags];
}

// 保存标签到 localStorage
function saveTags(tags) {
    localStorage.setItem('geo_highlight_tags', JSON.stringify(tags));
}

// 渲染标签到页面
function renderTags() {
    const container = document.getElementById('highlight-tags');
    if (!container) return;
    
    const tags = loadTags();
    
    container.innerHTML = tags.map((tag, index) => `
        <div class="tag ${tag.selected ? 'selected' : ''}" 
             onclick="toggleTag(${index})">
            ${tag.name}
            <span class="delete-btn" onclick="event.stopPropagation(); deleteTag(${index})">×</span>
        </div>
    `).join('');
    
    // 更新标签统计
    updateTagStats();
}

// 切换标签选中状态
function toggleTag(index) {
    const tags = loadTags();
    tags[index].selected = !tags[index].selected;
    saveTags(tags);
    renderTags();
}

// 删除标签
function deleteTag(index) {
    const tags = loadTags();
    const deletedTag = tags[index];
    tags.splice(index, 1);
    saveTags(tags);
    renderTags();
    showToast(`🗑️ 已删除「${deletedTag.name}」标签`);
}

// 添加新标签
function addNewTag() {
    const input = document.getElementById('new-tag-input');
    if (!input) return;
    
    const tagName = input.value.trim();
    if (!tagName) {
        showToast('⚠️ 请输入标签名称');
        return;
    }
    
    const tags = loadTags();
    
    // 检查是否已存在
    if (tags.some(tag => tag.name === tagName)) {
        showToast('⚠️ 该标签已存在');
        return;
    }
    
    tags.push({ name: tagName, selected: false });
    saveTags(tags);
    renderTags();
    
    // 清空输入框
    input.value = '';
    showToast(`✅ 已添加「${tagName}」标签`);
}

// 更新标签统计
function updateTagStats() {
    const tags = loadTags();
    const selectedCount = tags.filter(tag => tag.selected).length;
    const totalCount = tags.length;
    
    const statsEl = document.getElementById('tag-stats');
    if (statsEl) {
        statsEl.textContent = `已选 ${selectedCount} / 共 ${totalCount}`;
    }
}

// Toast 提示
function showToast(message) {
    // 移除现有的 toast
    const existingToast = document.querySelector('.toast-message');
    if (existingToast) {
        existingToast.remove();
    }
    
    const toast = document.createElement('div');
    toast.className = 'toast-message';
    toast.textContent = message;
    toast.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        padding: 12px 20px;
        background: #333;
        color: #fff;
        border-radius: 8px;
        z-index: 10000;
        animation: slideIn 0.3s ease-out;
    `;
    
    document.body.appendChild(toast);
    
    // 3秒后自动消失
    setTimeout(() => {
        toast.style.opacity = '0';
        toast.style.transition = 'opacity 0.3s';
        setTimeout(() => toast.remove(), 300);
    }, 3000);
}

// 页面加载时初始化标签
document.addEventListener('DOMContentLoaded', function() {
    renderTags();
    
    // 为输入框绑定回车事件
    const input = document.getElementById('new-tag-input');
    if (input) {
        input.addEventListener('keypress', function(e) {
            if (e.key === 'Enter') {
                e.preventDefault();
                addNewTag();
            }
        });
    }
});

// 导出函数供外部使用
if (typeof window !== 'undefined') {
    window.loadTags = loadTags;
    window.saveTags = saveTags;
    window.renderTags = renderTags;
    window.toggleTag = toggleTag;
    window.deleteTag = deleteTag;
    window.addNewTag = addNewTag;
    window.showToast = showToast;
}
