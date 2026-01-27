# Agent Workspace Orchestrator
# 快速原型 - 多 Claude Code Agents 協作系統

# 默認 recipe
default:
    @just --list

# 初始化工作區 - 啟動 tmux session
init-workspace:
    @just _init_tmux
    @echo "✅ Agent Workspace 已啟動！"
    @echo "📌 使用 Ctrl+b w 切換 window"
    @echo "📌 使用 Ctrl+b , 重新命名 window"

# 啟動單個 agent
spawn-agent name:
    @just _spawn_agent {{name}}

# 發送命令到指定 window
send-cmd target cmd:
    @just _send_command {{target}} "{{cmd}}"

# 列出所有 agents
list-agents:
    @just _list_agents

# 清理工作區
cleanup:
    @just _cleanup

# ===== Internal Recipes =====

# 初始化 tmux session
_init_tmux:
    #!/usr/bin/env bash
    SESSION="agent-workspace"

    # 檢查 session 是否已存在
    if tmux has-session -t $SESSION 2>/dev/null; then
        echo "⚠️  Session '$SESSION' 已存在"
        echo "附加到現有 session..."
        tmux attach-session -t $SESSION
        exit 0
    fi

    # 創建新 session
    echo "🚀 創建 tmux session: $SESSION"

    # 創建主控 window
    tmux new-session -d -s $SESSION -n "commander"
    tmux send-keys -t $SESSION:commander "cd {{justfile_directory()}}" C-m
    tmux send-keys -t $SESSION:commander "echo '⚡ Commander Window - 指揮中心'" C-m
    tmux send-keys -t $SESSION:commander "echo '使用 just send-cmd <target> <cmd> 發送命令'" C-m

    # 創建第一個 agent window（示例）
    tmux new-window -t $SESSION -n "agent-1"
    tmux send-keys -t $SESSION:agent-1 "cd {{justfile_directory()}}" C-m
    tmux send-keys -t $SESSION:agent-1 "echo '🤖 Agent-1 Ready - 等待指令'" C-m

    # 設置 layout
    tmux select-layout -t $SESSION even-horizontal

    # 附加到 session
    tmux attach-session -t $SESSION

# 在新 window 啟動 agent
_spawn_agent name:
    #!/usr/bin/env bash
    SESSION="agent-workspace"
    AGENT_NAME="{{name}}"

    if ! tmux has-session -t $SESSION 2>/dev/null; then
        echo "❌ Session '$SESSION' 不存在"
        echo "請先執行: just init-workspace"
        exit 1
    fi

    echo "🤖 啟動 Agent: $AGENT_NAME"

    # 創建新 window
    tmux new-window -t $SESSION -n "$AGENT_NAME"
    tmux send-keys -t $SESSION:"$AGENT_NAME" "cd {{justfile_directory()}}" C-m
    tmux send-keys -t $SESSION:"$AGENT_NAME" "echo '🤖 $AGENT_NAME Ready - 等待 Claude Code 指令'" C-m

    echo "✅ Agent '$AGENT_NAME' 已啟動"
    echo "💡 使用: just send-cmd $AGENT_NAME 'your-command'"

# 發送命令到指定 window
_send_command target cmd:
    #!/usr/bin/env bash
    SESSION="agent-workspace"
    TARGET="{{target}}"
    CMD="{{cmd}}"

    if ! tmux has-session -t $SESSION 2>/dev/null; then
        echo "❌ Session '$SESSION' 不存在"
        exit 1
    fi

    if ! tmux list-windows -t $SESSION | grep -q "$TARGET"; then
        echo "❌ Window '$TARGET' 不存在"
        echo "可用的 windows:"
        tmux list-windows -t $SESSION | sed 's/:/ → /'
        exit 1
    fi

    echo "📤 發送命令到 '$TARGET': $CMD"
    tmux send-keys -t $SESSION:"$TARGET" "$CMD" C-m

# 列出所有 agents
_list_agents:
    #!/usr/bin/env bash
    SESSION="agent-workspace"

    if ! tmux has-session -t $SESSION 2>/dev/null; then
        echo "❌ Session '$SESSION' 不存在"
        exit 1
    fi

    echo "📋 Agent 列表:"
    echo ""
    tmux list-windows -t $SESSION | while read line; do
        window_name=$(echo "$line" | grep -oP '\d+:\K[^ ]+(?=\*)?[^ ]*')
        window_index=$(echo "$line" | grep -oP '^\d+')
        echo "  [$window_index] $window_name"
    done

# 清理工作區
_cleanup:
    #!/usr/bin/env bash
    SESSION="agent-workspace"

    if tmux has-session -t $SESSION 2>/dev/null; then
        echo "🧹 關閉 session: $SESSION"
        tmux kill-session -t $SESSION
        echo "✅ 清理完成"
    else
        echo "ℹ️  Session '$SESSION' 不存在"
    fi
