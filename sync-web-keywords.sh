#!/bin/bash
# 处理从网页端导出的关键词配置并更新系统

SCRIPT_DIR=$(dirname "$0")
GEO_FILE="$SCRIPT_DIR/index.html"

# 检查是否提供了配置文件路径
if [ -z "$1" ]; then
    echo "❌ 请提供关键词配置文件路径"
    echo "用法: $0 <keywords-config-YYYY-MM-DD.js>"
    exit 1
fi

CONFIG_FILE="$1"

# 检查配置文件是否存在
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ 配置文件不存在: $CONFIG_FILE"
    exit 1
fi

echo "📝 开始处理关键词配置..."

# 提取关键词配置中的JSON部分
# 查找 exportedKeywords = { 开始，找到对应的 } 结束
KEYWORDS_JSON=$(sed -n '/exportedKeywords = /,/}/p' "$CONFIG_FILE" | sed 's/exportedKeywords = //' | sed 's/;$//')

# 验证JSON是否有效
if ! echo "$KEYWORDS_JSON" | python3 -m json.tool > /dev/null 2>&1; then
    echo "❌ 配置文件格式无效，无法解析JSON"
    exit 1
fi

echo "✅ 关键词配置解析成功"

# 使用Python脚本更新HTML文件中的defaultKeywords
python3 << EOF
import json
import re

# 读取配置文件中的关键词
keywords_json = '''$KEYWORDS_JSON'''
keywords = json.loads(keywords_json)

# 读取HTML文件
with open('$GEO_FILE', 'r', encoding='utf-8') as f:
    html_content = f.read()

# 构建新的关键词组字符串
def format_keywords_array(kw_list):
    formatted = []
    for kw in kw_list:
        formatted.append(f"    '{kw}'")
    return '[\n' + ',\n'.join(formatted) + '\n  ]'

buy_str = format_keywords_array(keywords['buy'])
edu_str = format_keywords_array(keywords['edu'])
scene_str = format_keywords_array(keywords['scene'])

# 替换defaultKeywords中的各个数组
# 找到 buy: [ 开始，找到对应的 ] 结束
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

print("✅ 关键词已更新到HTML文件")
print(f"  - buy组: {len(keywords['buy'])}个")
print(f"  - edu组: {len(keywords['edu'])}个")
print(f"  - scene组: {len(keywords['scene'])}个")
EOF

if [ $? -eq 0 ]; then
    echo ""
    echo "🚀 准备同步到GitHub Pages..."
    
    # 提交更改
    cd "$SCRIPT_DIR"
    git add index.html
    git commit -m "$(date +'%Y-%m-%d %H:%M:%S') - 更新关键词配置：用户网页端编辑"
    
    # 推送到GitHub
    git -c http.version=HTTP/1.1 push origin main
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "✅ 同步完成！"
        echo "🌐 请刷新网页查看更新：https://koolboy1978-ctrl.github.io/koolboy1978-ctrl/index.html"
        echo "⏱️  GitHub Pages通常需要1-2分钟完成部署"
    else
        echo "❌ 推送到GitHub失败"
        exit 1
    fi
else
    echo "❌ 更新关键词配置失败"
    exit 1
fi