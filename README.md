# Agent Workspace Orchestrator

> ⚡ 你的 AI 指揮中心 - 多 Claude Code Agents 協作系統

## 🎯 這是什麼？

一個極簡的 **Agent Orchestration 工具**，使用 **tmux + just** 實現：
- 一個指揮官窗口（coordinator）
- 多個 Agent 窗口（workers）
- 從指揮官窗口發送命令到各個 agents

## 🚀 快速開始

### 1. 初始化工作區

```bash
cd agent-workspace
just init-workspace
```

這會啟動一個 tmux session，包含：
- **commander** window - 你的指揮中心
- **agent-1** window - 第一個 agent

### 2. 啟動更多 Agents

```bash
# 在 commander window 或另一個 terminal
just spawn-agent agent-2
just spawn-agent agent-3
```

### 3. 發送命令到 Agents

```bash
# 從任何地方發送命令
just send-cmd agent-1 "echo 'Hello Agent 1'"
just send-cmd agent-2 "pwd"
just send-cmd commander "just list-agents"
```

### 4. 列出所有 Agents

```bash
just list-agents
```

### 5. 清理工作區

```bash
just cleanup
```

## 📁 專案結構

```
agent-workspace/
├── justfile              # 任務運行器配置
├── bin/
│   └── start-agent.sh    # Agent 啟動腳本
├── config/
│   └── agents.yaml       # Agent 配置（未來使用）
├── logs/                 # 日誌目錄
└── README.md
```

## 🎹 tmux 快捷鍵

在 tmux session 中：

- `Ctrl+b w` - 顯示所有 windows
- `Ctrl+b 0-9` - 切換到指定 window
- `Ctrl+b ,` - 重新命名當前 window
- `Ctrl+b n` - 下一個 window
- `Ctrl+b p` - 上一個 window
- `Ctrl+b d` - 分離 session（後台運行）

## 🔧 未來功能

- [ ] Agent 配置文件（YAML）
- [ ] 任務依賴管理
- [ ] 自動化工作流
- [ ] Agent 間通訊
- [ ] 狀態監控和日誌
- [ ] 視覺化 dashboard

## 💡 使用場景

### 場景 1: 並行開發

```bash
# Window 1 (commander)
just send-cmd agent-1 "claude-code implement feature A"
just send-cmd agent-2 "claude-code write tests for feature A"
just send-cmd agent-3 "claude-code review code"
```

### 場景 2: 研究 + 實作

```bash
# Agent-1 研究，Agent-2 實作
just send-cmd agent-1 "claude-code research best practices for X"
just send-cmd agent-2 "claude-code implement X based on research"
```

### 場景 3: 代碼審查循環

```bash
# 開發 → 審查 → 修正
just send-cmd agent-1 "claude-code implement feature"
just send-cmd agent-2 "claude-code review feature"
just send-cmd agent-1 "claude-code fix issues from review"
```

## 🎓 學習重點

這個項目讓你學習：

1. **tmux 自動化** - Session 和 window 管理
2. **Agent Orchestration** - 多 agents 協作模式
3. **Shell Scripting** - 自動化工具開發
4. **Just** - 現代任務運行器
5. **YAML 配置** - 結構化配置管理

## 🛣️ 路線圖

### Phase 1: 基礎設施 ✅
- [x] tmux session 管理
- [x] 基礎命令發送
- [x] justfile 任務定義

### Phase 2: Agent Orchestration 🚧
- [ ] Agent 配置系統
- [ ] 任務分配邏輯
- [ ] 事件監聽機制

### Phase 3: 智能協作 🔮
- [ ] Agent 間通訊協議
- [ ] 共享上下文
- [ ] 工作流視覺化

## 📝 授權

MIT - 開源實驗項目

---

**Built with ❤️ for learning Agent Orchestration**
