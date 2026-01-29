#!/usr/bin/env bash
# Agent API - AI-friendly interface for agent workspace control
# Designed for Claude Code and other AI agents to automate agent orchestration

set -e

# Configuration
SESSION="${AGENT_WORKSPACE_SESSION:-agent-workspace}"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Colors for output (optional, can be disabled with AGENT_API_NO_COLOR=1)
if [[ -z "$AGENT_API_NO_COLOR" ]]; then
    COLOR_ERROR='\033[0;31m'
    COLOR_SUCCESS='\033[0;32m'
    COLOR_INFO='\033[0;34m'
    COLOR_RESET='\033[0m'
else
    COLOR_ERROR=''
    COLOR_SUCCESS=''
    COLOR_INFO=''
    COLOR_RESET=''
fi

# Helper functions
error() {
    echo -e "${COLOR_ERROR}ERROR: $1${COLOR_RESET}" >&2
}

success() {
    echo -e "${COLOR_SUCCESS}SUCCESS: $1${COLOR_RESET}"
}

info() {
    echo -e "${COLOR_INFO}INFO: $1${COLOR_RESET}"
}

# Check if tmux session exists
check_session() {
    if ! tmux has-session -t "$SESSION" 2>/dev/null; then
        error "Session '$SESSION' does not exist"
        echo "Run: agent-api init"
        exit 1
    fi
}

# Command: init - Initialize workspace
api_init() {
    if tmux has-session -t "$SESSION" 2>/dev/null; then
        info "Session '$SESSION' already exists"
        return 0
    fi

    info "Creating tmux session: $SESSION"

    # Create commander window
    tmux new-session -d -s "$SESSION" -n "commander"
    tmux send-keys -t "$SESSION:commander" "cd \"$PROJECT_ROOT\"" C-m
    tmux send-keys -t "$SESSION:commander" "echo '⚡ Commander Window - 指揮中心'" C-m

    # Create agent-1 window
    tmux new-window -t "$SESSION" -n "agent-1"
    tmux send-keys -t "$SESSION:agent-1" "cd \"$PROJECT_ROOT\"" C-m
    tmux send-keys -t "$SESSION:agent-1" "echo '🤖 Agent-1 Ready'" C-m

    # Set layout
    tmux select-layout -t "$SESSION" even-horizontal

    success "Workspace initialized with commander and agent-1"
    echo "Windows: commander, agent-1"
}

# Command: list - List all agents
api_list() {
    check_session

    echo "AGENTS:"
    tmux list-windows -t "$SESSION" -F "#{window_index}:#{window_name}" | while read -r line; do
        local index="${line%%:*}"
        local name="${line##*:}"
        echo "  [$index] $name"
    done
}

# Command: spawn <name> - Create new agent
api_spawn() {
    local agent_name="$1"

    if [[ -z "$agent_name" ]]; then
        error "Agent name required"
        echo "Usage: agent-api spawn <name>"
        exit 1
    fi

    check_session

    # Check if window already exists
    if tmux list-windows -t "$SESSION" -F "#{window_name}" | grep -q "^${agent_name}$"; then
        error "Agent '$agent_name' already exists"
        exit 1
    fi

    info "Creating agent: $agent_name"

    # Create new window
    tmux new-window -t "$SESSION" -n "$agent_name"
    tmux send-keys -t "$SESSION:$agent_name" "cd \"$PROJECT_ROOT\"" C-m
    tmux send-keys -t "$SESSION:$agent_name" "echo '🤖 $agent_name Ready'" C-m

    success "Agent '$agent_name' created"
    echo "Window: $agent_name"
}

# Command: send <name> <command> - Send command to agent
api_send() {
    local agent_name="$1"
    local cmd="$2"

    if [[ -z "$agent_name" ]] || [[ -z "$cmd" ]]; then
        error "Agent name and command required"
        echo "Usage: agent-api send <name> <command>"
        exit 1
    fi

    check_session

    # Check if window exists
    if ! tmux list-windows -t "$SESSION" -F "#{window_name}" | grep -q "^${agent_name}$"; then
        error "Agent '$agent_name' not found"
        echo "Available agents:"
        api_list
        exit 1
    fi

    info "Sending command to '$agent_name': $cmd"

    # Send command
    tmux send-keys -t "$SESSION:$agent_name" "$cmd" C-m

    success "Command sent to '$agent_name'"
}

# Command: status <name> - Check agent status
api_status() {
    local agent_name="$1"

    if [[ -z "$agent_name" ]]; then
        error "Agent name required"
        echo "Usage: agent-api status <name>"
        exit 1
    fi

    check_session

    # Check if window exists
    if ! tmux list-windows -t "$SESSION" -F "#{window_name}" | grep -q "^${agent_name}$"; then
        error "Agent '$agent_name' not found"
        echo "Available agents:"
        api_list
        exit 1
    fi

    # Get window info
    local window_info=$(tmux list-windows -t "$SESSION" -F "#{window_name}:#{window_index}:#{window_width}x#{window_height}" | grep "^${agent_name}:")
    local name="${window_info%%:*}"
    local rest="${window_info#*:}"
    local index="${rest%%:*}"
    local dimensions="${rest#*:}"

    echo "AGENT STATUS: $agent_name"
    echo "  Window Index: $index"
    echo "  Dimensions: $dimensions"
    echo "  Session: $SESSION"
    echo "  State: active"
}

# Command: parallel-spawn <name1,name2,...> - Create multiple agents in parallel
api_parallel_spawn() {
    local agent_list="$1"

    if [[ -z "$agent_list" ]]; then
        error "Agent list required"
        echo "Usage: agent-api parallel-spawn <name1,name2,...>"
        exit 1
    fi

    check_session

    # Convert comma-separated list to array
    IFS=',' read -ra agents <<< "$agent_list"
    local total=${#agents[@]}
    local count=0
    local pids=()

    info "Spawning $total agents in parallel..."

    for agent_name in "${agents[@]}"; do
        # Trim whitespace
        agent_name=$(echo "$agent_name" | xargs)

        # Skip if empty
        [[ -z "$agent_name" ]] && continue

        # Check if already exists
        if tmux list-windows -t "$SESSION" -F "#{window_name}" | grep -q "^${agent_name}$"; then
            echo "⚠️  Skipped '$agent_name' (already exists)"
            ((count++)) || true
            continue
        fi

        # Spawn in background
        (
            tmux new-window -t "$SESSION" -n "$agent_name" 2>/dev/null
            tmux send-keys -t "$SESSION:$agent_name" "cd \"$PROJECT_ROOT\"" C-m 2>/dev/null
            tmux send-keys -t "$SESSION:$agent_name" "echo '🤖 $agent_name Ready'" C-m 2>/dev/null
        ) &
        pids+=($!)

        ((count++)) || true
        echo "🔄 [$count/$total] Spawning '$agent_name'..."
    done

    # Wait for all background jobs
    local failed=0
    for pid in "${pids[@]}"; do
        if ! wait $pid 2>/dev/null; then
            ((failed++)) || true
        fi
    done

    if [[ $failed -gt 0 ]]; then
        error "Some agents failed to spawn ($failed/$total failed)"
    else
        success "Parallel spawn complete ($total agents created)"
    fi
}

# Command: parallel-send <name1,name2,...> <cmd> - Send command to multiple agents in parallel
api_parallel_send() {
    local agent_list="$1"
    local cmd="$2"

    if [[ -z "$agent_list" ]] || [[ -z "$cmd" ]]; then
        error "Agent list and command required"
        echo "Usage: agent-api parallel-send <name1,name2,...> <command>"
        exit 1
    fi

    check_session

    # Convert comma-separated list to array
    IFS=',' read -ra agents <<< "$agent_list"
    local total=${#agents[@]}
    local count=0
    local pids=()

    info "Sending command to $total agents in parallel..."

    for agent_name in "${agents[@]}"; do
        # Trim whitespace
        agent_name=$(echo "$agent_name" | xargs)

        # Skip if empty
        [[ -z "$agent_name" ]] && continue

        # Check if window exists
        if ! tmux list-windows -t "$SESSION" -F "#{window_name}" | grep -q "^${agent_name}$"; then
            echo "⚠️  Skipped '$agent_name' (not found)"
            ((count++)) || true
            continue
        fi

        # Send in background
        (
            tmux send-keys -t "$SESSION:$agent_name" "$cmd" C-m 2>/dev/null
        ) &
        pids+=($!)

        ((count++)) || true
        echo "📤 [$count/$total] Sent to '$agent_name'"
    done

    # Wait for all background jobs
    local failed=0
    for pid in "${pids[@]}"; do
        if ! wait $pid 2>/dev/null; then
            ((failed++)) || true
        fi
    done

    if [[ $failed -gt 0 ]]; then
        error "Some commands failed ($failed/$total failed)"
    else
        success "Parallel send complete ($total agents targeted)"
    fi
}

# Command: help - Show usage
api_help() {
    cat <<EOF
Agent API - AI-friendly interface for agent workspace control

USAGE:
  agent-api <command> [arguments]

COMMANDS:
  init                           Initialize workspace (create tmux session)
  list                           List all agents
  spawn <name>                   Create new agent window
  send <name> <cmd>              Send command to agent
  status <name>                  Check agent status
  parallel-spawn <name1,name2,...>  Create multiple agents in parallel
  parallel-send <name1,name2,...> <cmd>  Send command to multiple agents in parallel
  help                           Show this help message

ENVIRONMENT VARIABLES:
  AGENT_WORKSPACE_SESSION  Session name (default: agent-workspace)
  AGENT_API_NO_COLOR=1     Disable colored output

EXAMPLES:
  agent-api init
  agent-api list
  agent-api spawn researcher
  agent-api send agent-1 "pwd"
  agent-api status agent-1
  agent-api parallel-spawn agent-2,agent-3,agent-4
  agent-api parallel-send agent-1,agent-2,agent-3 "echo 'Hello'"

EXIT CODES:
  0 - Success
  1 - Error (agent/session not found, invalid command, etc.)
EOF
}

# Main dispatcher
main() {
    local command="$1"
    shift || true

    case "$command" in
        init)
            api_init
            ;;
        list)
            api_list
            ;;
        spawn)
            api_spawn "$@"
            ;;
        send)
            api_send "$@"
            ;;
        status)
            api_status "$@"
            ;;
        parallel-spawn)
            api_parallel_spawn "$@"
            ;;
        parallel-send)
            api_parallel_send "$@"
            ;;
        help|--help|-h)
            api_help
            ;;
        *)
            error "Unknown command: $command"
            echo ""
            api_help
            exit 1
            ;;
    esac
}

main "$@"
