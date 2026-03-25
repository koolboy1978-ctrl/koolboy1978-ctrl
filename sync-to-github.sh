#!/bin/bash
# 自动同步geo-system到GitHub Pages的脚本

cd /Users/apple/WorkBuddy/20260319150622/geo-system

# 检查是否有未提交的更改
if ! git diff-index --quiet HEAD --; then
    echo "📝 检测到未提交的更改..."
    
    # 提交更改
    git add index.html
    git commit -m "$(date +'%Y-%m-%d %H:%M:%S') - 自动更新GEO系统"
    
    echo "✅ 提交成功"
fi

# 尝试推送到GitHub（使用HTTP/1.1避免HTTP2协议问题）
echo "🚀 正在推送到GitHub Pages..."
git -c http.version=HTTP/1.1 push origin main

if [ $? -eq 0 ]; then
    echo "✅ 推送成功！GitHub Pages已更新"
    echo "🌐 访问地址: https://koolboy1978-ctrl.github.io/koolboy1978-ctrl/index.html"
else
    echo "❌ 推送失败，请检查网络连接或GitHub认证"
    echo "💡 提示: 可能需要更新GitHub Personal Access Token"
fi