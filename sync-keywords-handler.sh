#!/bin/bash
# 关键词同步处理器

SYNC_MARKER="$1"
SCRIPT_DIR=$(dirname "$SYNC_MARKER")
GEO_FILE="$SCRIPT_DIR/index.html"

echo "🔄 开始同步关键词..."

python3 << EOF
import json
import re

# 读取同步数据
with open('$SYNC_MARKER', 'r') as f:
    sync_data = json.load(f)

keywords = sync_data.get('data', {})
timestamp = sync_data.get('timestamp', 'unknown')

if not keywords:
    print("❌ 无效的关键词数据")
    exit(1)

# 读取HTML文件
with open('$GEO_FILE', 'r', encoding='utf-8') as f:
    html_content = f.read()

# 构建新的关键词组字符串
def format_keywords_array(kw_list):
    formatted = []
    for kw in kw_list:
        formatted.append(f"    '{kw}'")
    return '[\n' + ',\n'.join(formatted) + '\n  ]'

buy_str = format_keywords_array(keywords.get('buy', []))
edu_str = format_keywords_array(keywords.get('edu', []))
scene_str = format_keywords_array(keywords.get('scene', []))

# 替换defaultKeywords中的各个数组
html_content = re.sub(
    r'buy: \[.*?\n  \],',
    f'buy: {buy_str},',
    html_content,
    flags=re.DOTALL
)

html_content = re.sub(
    r'edu: \[.*?\n  \],',
    f'edu: {edu_str},',
    html_content,
    flags=re.DOTALL
)

html_content = re.sub(
    r'scene: \[.*?\n\};',
    f'scene: {scene_str}\n};',
    html_content,
    flags=re.DOTALL
)

# 写回文件
with open('$GEO_FILE', 'w', encoding='utf-8') as f:
    f.write(html_content)

print(f"✅ 关键词已更新")
print(f"  - 采购决策词: {len(keywords.get('buy', []))}个")
print(f"  - 科普认知词: {len(keywords.get('edu', []))}个")
print(f"  - 场景应用词: {len(keywords.get('scene', []))}个")
print(f"  - 修改时间: {timestamp}")
EOF

if [ $? -eq 0 ]; then
    bash "$SCRIPT_DIR/commit-sync.sh" "$SYNC_MARKER" "关键词"
else
    echo "❌ 关键词同步失败"
    exit 1
fi