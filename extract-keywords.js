// 在浏览器控制台中运行此脚本，提取关键词数据并生成同步标记文件

// 1. 从localStorage读取关键词数据
const keywordsStr = localStorage.getItem('geo_keywords_pending');
const syncTime = localStorage.getItem('geo_keywords_sync_time');
const syncNeeded = localStorage.getItem('geo_keywords_sync_needed');

if (!keywordsStr || syncNeeded !== 'true') {
    console.log('ℹ️  没有待同步的关键词修改');
    console.log('💡 提示：请在网页端点击"保存关键词"按钮后再运行此脚本');
} else {
    const keywords = JSON.parse(keywordsStr);
    
    // 2. 生成同步数据
    const syncData = {
        keywords: keywords,
        timestamp: syncTime,
        synced: false
    };
    
    // 3. 显示数据到控制台（复制给WorkBuddy）
    console.log('📝 关键词同步数据：');
    console.log(JSON.stringify(syncData, null, 2));
    
    // 4. 生成下载链接
    const blob = new Blob([JSON.stringify(syncData, null, 2)], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    
    const a = document.createElement('a');
    a.href = url;
    a.download = 'keywords-sync.json';
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
    
    console.log('✅ 同步数据已下载为 keywords-sync.json');
    console.log('📋 请将此文件发送给WorkBuddy进行自动同步');
    
    // 5. 显示统计信息
    const total = keywords.buy.length + keywords.edu.length + keywords.scene.length;
    console.log('📊 关键词统计：');
    console.log(`  - 采购决策词：${keywords.buy.length}个`);
    console.log(`  - 科普认知词：${keywords.edu.length}个`);
    console.log(`  - 场景应用词：${keywords.scene.length}个`);
    console.log(`  - 总计：${total}个关键词`);
}
