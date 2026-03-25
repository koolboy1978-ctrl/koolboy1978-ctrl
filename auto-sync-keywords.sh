#!/bin/bash
# 自动监控并同步网页端的各种修改到GitHub

SCRIPT_DIR=$(dirname "$0")
GEO_FILE="$SCRIPT_DIR/index.html"
SYNC_MARKER="$SCRIPT_DIR/.sync_data_pending"

echo "🔍 检查待同步数据..."

# 检查是否存在同步标记文件
if [ ! -f "$SYNC_MARKER" ]; then
    echo "✅ 无待同步的修改"
    exit 0
fi

# 读取同步标记文件内容
SYNC_DATA=$(cat "$SYNC_MARKER")
SYNC_TYPE=$(echo "$SYNC_DATA" | python3 -c "import sys, json; print(json.load(sys.stdin).get('type', 'unknown'))")

echo "📝 发现待同步的修改类型：$SYNC_TYPE"

# 根据不同类型执行不同的同步逻辑
case "$SYNC_TYPE" in
    "keywords")
        bash "$SCRIPT_DIR/sync-keywords-handler.sh" "$SYNC_MARKER"
        ;;
    "kb")
        bash "$SCRIPT_DIR/sync-kb-handler.sh" "$SYNC_MARKER"
        ;;
    "content")
        bash "$SCRIPT_DIR/sync-content-handler.sh" "$SYNC_MARKER"
        ;;
    "api")
        bash "$SCRIPT_DIR/sync-api-handler.sh" "$SYNC_MARKER"
        ;;
    *)
        echo "❌ 未知的同步类型：$SYNC_TYPE"
        exit 1
        ;;
esac