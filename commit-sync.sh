#!/bin/bash
# 通用的同步提交脚本

SYNC_MARKER="$1"
SYNC_TYPE="$2"
SCRIPT_DIR=$(dirname "$SYNC_MARKER")
GEO_FILE="$SCRIPT_DIR/index.html"

echo "🚀 正在同步到GitHub Pages..."

# 提交更改
cd "$SCRIPT_DIR"
git add index.html

# 从同步标记中读取修改信息
COMMIT_MSG=$(python3 << EOF
import json
import datetime

with open('$SYNC_MARKER', 'r') as f:
    sync_data = json.load(f)

timestamp = sync_data.get('timestamp', 'unknown')
data = sync_data.get('data', {})

if '$SYNC_TYPE' == '关键词':
    total = len(data.get('buy', [])) + len(data.get('edu', [])) + len(data.get('scene', []))
    print(f"{timestamp} - 更新关键词配置：{total}个关键词")
elif '$SYNC_TYPE' == '知识库':
    base = data.get('base', {})
    usp = data.get('usp', [])
    print(f"{timestamp} - 更新知识库：{base.get('brand', '品牌')} · {len(usp)}个卖点")
elif '$SYNC_TYPE' == '内容':
    count = len(data) if isinstance(data, list) else 1
    print(f"{timestamp} - 保存内容：{count}篇")
elif '$SYNC_TYPE' == 'API配置':
    print(f"{timestamp} - 更新API配置")
else:
    print(f"{timestamp} - 更新${SYNC_TYPE}")
EOF
)

git commit -m "$COMMIT_MSG"

# 推送到GitHub
git -c http.version=HTTP/1.1 push origin main

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ 同步完成！"
    echo "🌐 请刷新网页查看更新：https://koolboy1978-ctrl.github.io/koolboy1978-ctrl/index.html"
    echo "⏱️  GitHub Pages通常需要1-2分钟完成部署"
    
    # 删除同步标记文件
    rm "$SYNC_MARKER"
    echo "🗑️  同步标记已清理"
else
    echo "❌ 推送到GitHub失败"
    exit 1
fi