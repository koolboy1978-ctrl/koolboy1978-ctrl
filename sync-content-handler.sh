#!/bin/bash
# 内容同步处理器（暂时只记录，不修改HTML）

SYNC_MARKER="$1"
SCRIPT_DIR=$(dirname "$SYNC_MARKER")

echo "🔄 内容修改已记录"
echo "💡 提示：内容数据已保存到localStorage，此功能暂不自动同步到HTML文件"

python3 << EOF
import json

with open('$SYNC_MARKER', 'r') as f:
    sync_data = json.load(f)

data = sync_data.get('data', [])
count = len(data) if isinstance(data, list) else 1

print(f"  - 内容数量: {count}篇")
EOF

# 对于内容，我们只同步标记文件本身，不修改HTML
bash "$SCRIPT_DIR/commit-sync.sh" "$SYNC_MARKER" "内容"