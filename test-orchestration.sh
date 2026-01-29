#!/usr/bin/env bash
# 快速測試 Agent Orchestration（不需要 tmux session）

set -e

echo "🧪 Agent Workspace Orchestrator - 快速測試"
echo "=========================================="
echo ""

# 測試 1: 檢查依賴
echo "📋 測試 1: 檢查依賴"
if command -v tmux &> /dev/null; then
    echo "✅ tmux: $(tmux -V)"
else
    echo "❌ tmux 未安裝"
    exit 1
fi

if command -v just &> /dev/null; then
    echo "✅ just: $(just --version)"
else
    echo "❌ just 未安裝"
    exit 1
fi

echo ""

# 測試 2: 驗證 justfile 配置
echo "📋 測試 2: 驗證 justfile 配置"
cd "$(dirname "$0")"

if just --list &> /dev/null; then
    echo "✅ justfile 配置正確"
    echo ""
    echo "可用的命令："
    just --list
else
    echo "❌ justfile 有語法錯誤"
    exit 1
fi

echo ""

# 測試 3: 檢查檔案結構
echo "📋 測試 3: 檢查檔案結構"
files=(
    "justfile"
    "bin/start-agent.sh"
    "bin/agent-api.sh"
    "config/agents.yaml"
    "README.md"
)

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file"
    else
        echo "❌ $file 缺失"
    fi
done

echo ""

# 測試 4: 驗證 agent-api
echo "📋 測試 4: 驗證 agent-api"

# 檢查 agent-api 是否可執行
if [ -x "bin/agent-api.sh" ]; then
    echo "✅ agent-api.sh 可執行"
else
    echo "❌ agent-api.sh 不可執行"
    exit 1
fi

# 測試 agent-api help 命令
if bin/agent-api.sh help &> /dev/null; then
    echo "✅ agent-api help 命令正常"
else
    echo "❌ agent-api help 命令失敗"
    exit 1
fi

# 測試 agent-api 不存在的命令（應該返回 exit code 1）
if bin/agent-api.sh invalid-command &> /dev/null; then
    echo "❌ agent-api 錯誤處理失敗（應該返回非零 exit code）"
    exit 1
else
    echo "✅ agent-api 錯誤處理正常"
fi

echo ""
echo "=========================================="
echo "🎉 所有測試通過！"
echo ""
echo "🚀 下一步："
echo "   1. 啟動工作區: cd agent-workspace && just init-workspace"
echo "   2. 或使用 agent-api: bin/agent-api.sh init"
echo "   3. 或查看 README: cat agent-workspace/README.md"
echo ""
