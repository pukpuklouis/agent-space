#!/usr/bin/env bash
# 在 tmux window 中啟動 Claude Code Agent

set -e

AGENT_NAME="${1:-agent-1}"
SESSION="${2:-agent-workspace}"

echo "🤖 啟動 Claude Code Agent: $AGENT_NAME"

# 檢查是否在 tmux session 中
if [ -z "$TMUX" ]; then
    echo "❌ 此腳本必須在 tmux session 中運行"
    echo "💡 使用: just spawn-agent <name>"
    exit 1
fi

# 初始化 agent
echo "🔧 初始化 Agent 配置..."
echo "📂 工作目錄: $(pwd)"
echo "🆔 Session: $SESSION"
echo "🤖 Agent: $AGENT_NAME"

# 這裡可以加入 Claude Code 的啟動邏輯
# 例如: 加載特定的 agent 配置、skill 設置等

echo ""
echo "✅ Agent $AGENT_NAME 就緒！"
echo "💡 現在可以使用 /command 開始與 Claude 互動"
echo ""
