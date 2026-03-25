// 修复 markPublished 函数，支持切换状态（已发布 ↔ 未发布）
function markPublished(platformName) {
  if (!_vmCurrentItem) return;
  const records = JSON.parse(localStorage.getItem('geo_publish_records') || '{}');
  if (!records[_vmCurrentItem.id]) records[_vmCurrentItem.id] = {};
  
  // 检查是否已发布，已发布则取消发布，未发布则标记为已发布
  if (records[_vmCurrentItem.id][platformName]) {
    delete records[_vmCurrentItem.id][platformName];
    
    // 如果该项目没有任何已发布的平台，则删除该项目的记录
    if (Object.keys(records[_vmCurrentItem.id]).length === 0) {
      delete records[_vmCurrentItem.id];
    }
    
    showToast(`🗑️ 已取消「${platformName}」的发布状态`);
  } else {
    const now = new Date().toLocaleDateString('zh-CN');
    records[_vmCurrentItem.id][platformName] = now;
    showToast(`✅ 已标记「${platformName}」发布成功`);
  }
  
  localStorage.setItem('geo_publish_records', JSON.stringify(records));
  renderPublishCards(_vmCurrentItem);
  
  // 更新底部状态
  const pubRecord = records[_vmCurrentItem.id];
  if (pubRecord && Object.keys(pubRecord).length > 0) {
    const labels = Object.entries(pubRecord).map(([p, t]) => `${p} ✅ ${t}`).join('  ·  ');
    document.getElementById('vm-publish-status').textContent = '已发布：' + labels;
  } else {
    document.getElementById('vm-publish-status').textContent = '';
  }
  
  // 更新数据看板
  updateStats();
}

// 更新数据看板统计
function updateStats() {
  const contents = state.contents || [];
  const records = JSON.parse(localStorage.getItem('geo_publish_records') || '{}');
  
  // 统计各平台已发布数量
  let zhihuCount = 0;
  let toutiaoCount = 0;
  let websiteCount = 0;
  
  contents.forEach(content => {
    const itemRecords = records[content.id] || {};
    if (itemRecords['zhihu']) zhihuCount++;
    if (itemRecords['toutiao']) toutiaoCount++;
    if (itemRecords['website']) websiteCount++;
  });
  
  // 更新显示
  const total = contents.length || 0;
  document.getElementById('stat-zhihu').textContent = `${zhihuCount} / ${total}`;
  document.getElementById('stat-toutiao').textContent = `${toutiaoCount} / ${total}`;
  document.getElementById('stat-website').textContent = `${websiteCount} / ${total}`;
}

// 初始化时调用一次
document.addEventListener('DOMContentLoaded', updateStats);
