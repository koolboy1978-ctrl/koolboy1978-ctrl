#!/bin/bash
# 处理从网页端发送的关键词同步数据

SCRIPT_DIR=$(dirname "$0")
SYNC_MARKER="$SCRIPT_DIR/.sync_keywords_pending"

# 检查是否提供了同步数据文件路径
if [ -z "$1" ]; then
    echo "❌ 请提供关键词同步数据文件路径"
    echo "用法: $0 <keywords-sync.json>"
    exit 1
fi

SYNC_FILE="$1"

# 检查同步文件是否存在
if [ ! -f "$SYNC_FILE" ]; then
    echo "❌ 同步数据文件不存在: $SYNC_FILE"
    exit 1
fi

echo "📝 开始处理关键词同步数据..."

# 验证JSON格式
if ! python3 -m json.tool "$SYNC_FILE" > /dev/null 2>&1; then
    echo "❌ 同步数据文件格式无效"
    exit 1
fi

# 将同步数据复制到标记文件
cp "$SYNC_FILE" "$SYNC_MARKER"

echo "✅ 同步数据已就绪"

# 执行自动同步
"$SCRIPT_DIR/auto-sync-keywords.sh"