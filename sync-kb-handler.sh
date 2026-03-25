#!/bin/bash
# 知识库同步处理器（暂时只记录，不修改HTML）

SYNC_MARKER="$1"
SCRIPT_DIR=$(dirname "$SYNC_MARKER")

echo "🔄 知识库修改已记录"
echo "💡 提示：知识库数据已保存到localStorage，此功能暂不自动同步到HTML文件"

python3 << EOF
import json

with open('$SYNC_MARKER', 'r') as f:
    sync_data = json.load(f)

base = sync_data.get('data', {}).get('base', {})
usp = sync_data.get('data', {}).get('usp', [])

print(f"  - 品牌名: {base.get('brand', '未设置')}")
print(f"  - 卖点数量: {len(usp)}个")
EOF

# 对于知识库，我们只同步标记文件本身，不修改HTML
bash "$SCRIPT_DIR/commit-sync.sh" "$SYNC_MARKER" "知识库"