#!/bin/bash
# 自动监控并同步网页端的关键词修改到GitHub

SCRIPT_DIR=$(dirname "$0")
GEO_FILE="$SCRIPT_DIR/index.html"
SYNC_MARKER="$SCRIPT_DIR/.sync_keywords_pending"

echo "🔍 检查关键词同步需求..."

# 检查是否存在同步标记文件
if [ ! -f "$SYNC_MARKER" ]; then
    echo "✅ 无待同步的关键词修改"
    exit 0
fi

# 读取同步标记文件内容
SYNC_DATA=$(cat "$SYNC_MARKER")

echo "📝 发现待同步的关键词修改"

# 解析关键词数据（JSON格式）
python3 << EOF
import json
import re

# 读取同步数据
try:
    with open('$SYNC_MARKER', 'r') as f:
        sync_data = json.load(f)
    
    keywords = sync_data.get('keywords', {})
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
    
except Exception as e:
    print(f"❌ 更新失败: {str(e)}")
    exit(1)
EOF

if [ $? -eq 0 ]; then
    echo ""
    echo "🚀 正在同步到GitHub Pages..."
    
    # 提交更改
    cd "$SCRIPT_DIR"
    git add index.html
    
    # 从同步标记中读取修改信息
    python3 << EOF
import json
import datetime

with open('$SYNC_MARKER', 'r') as f:
    sync_data = json.load(f)

timestamp = sync_data.get('timestamp', 'unknown')
keywords = sync_data.get('keywords', {})
total = len(keywords.get('buy', [])) + len(keywords.get('edu', [])) + len(keywords.get('scene', []))

print(f"{timestamp} - 更新关键词配置：{total}个关键词")
EOF

    git commit -F <(python3 << EOF
import json
import datetime

with open('$SYNC_MARKER', 'r') as f:
    sync_data = json.load(f)

timestamp = sync_data.get('timestamp', 'unknown')
keywords = sync_data.get('keywords', {})
total = len(keywords.get('buy', [])) + len(keywords.get('edu', [])) + len(keywords.get('scene', []))

print(f"{timestamp} - 更新关键词配置：{total}个关键词")
EOF
)
    
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
else
    echo "❌ 更新关键词配置失败"
    exit 1
fi