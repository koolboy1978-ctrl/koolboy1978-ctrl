#!/bin/bash
# API配置同步处理器（暂时只记录，不修改HTML）

SYNC_MARKER="$1"
SCRIPT_DIR=$(dirname "$SYNC_MARKER")

echo "🔄 API配置修改已记录"
echo "💡 提示：API配置已保存到localStorage，此功能暂不自动同步到HTML文件"

python3 << EOF
import json

with open('$SYNC_MARKER', 'r') as f:
    sync_data = json.load(f)

data = sync_data.get('data', {})
model = data.get('model', 'deepseek-chat')

print(f"  - 模型: {model}")
print(f"  - API Key: ***{data.get('apiKey', '')[-8:]}")
EOF

# 对于API配置，我们只同步标记文件本身，不修改HTML
bash "$SCRIPT_DIR/commit-sync.sh" "$SYNC_MARKER" "API配置"