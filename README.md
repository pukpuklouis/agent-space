# Agent Workspace

> ⚡ **AI Agent Orchestration 系統** - 學習 Multi-Agent 協作模式

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Phase 1: MVP](https://img.shields.io/badge/Phase-1%20%7C%20MVP-brightgreen.svg)](docs/ROADMAP.md)

## 🎯 專案簡介

**Agent Workspace** 是一個極簡的 **Agent Orchestration 工具**，使用 **tmux + just** 實現輕量級的多 AI Agents 協作系統。專注於實際應用，探索 Multi-Agent 協作的無限可能。

### 🚀 快速預覽

```bash
# 1. 初始化工作區
just init-workspace

# 2. 啟動更多 agents
just spawn-agent agent-2
just spawn-agent agent-3

# 3. 發送命令到各個 agents
just send-cmd agent-1 "claude-code implement feature A"
just send-cmd agent-2 "claude-code write tests"
just send-cmd agent-3 "claude-code review code"

# 4. 查看所有 agents
just list-agents
```

## 📚 為什麼這個專案？

### 專案目標

- 🎓 **Agent Orchestration** - 探索多 agent 協作模式
- 🔧 **Multi-Agent 協作** - 實作 agent 間通訊和協調
- 🤖 **AI 輔助開發** - 整合 Claude Code 進入 agent 系統
- 📐 **系統架構** - 構建高效分式系統

### 技術棧

| 技術 | 版本 | 用途 |
|------|------|------|
| **tmux** | 3.5a | Terminal multiplexer，workspace 管理 |
| **just** | 1.46.0 | Command runner，任務自動化 |
| **Shell** | - | Automation scripting |
| **YAML** | - | Agent 配置管理 |

### 設計原則

- **KISS**: 極致簡單，使用現有工具
- **YAGNI**: 只實作當前需要的功能
- **DRY**: 避免重複，配置驅動

## 🏗️ 架構概覽

```
tmux Session: "agent-workspace"
├── commander     → 指揮中心，協調其他 agents
├── agent-1       → 開發者，實作功能
├── agent-2       → 研究員，調研和文檔
└── agent-N       → 自定義 roles
```

詳細架構請參考：[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)

## 🚀 快速開始

### 前置需求

```bash
# macOS
brew install tmux just

# Linux (Ubuntu/Debian)
sudo apt install tmux just

# 驗證安裝
tmux -V    # should be 3.5a or later
just --version  # should be 1.46.0 or later
```

### 安裝

```bash
# 複製專案
git clone https://github.com/pukpuklouis/agent-space.git
cd agent-space

# 查看可用命令
just --list
```

### 基礎使用

#### 1. 初始化工作區

```bash
just init-workspace
```

這會啟動 tmux session，包含：
- **commander** window - 你的指揮中心
- **agent-1** window - 第一個 agent

#### 2. 啟動更多 Agents

```bash
# 在另一個 terminal 或 commander window
just spawn-agent agent-2
just spawn-agent agent-3
just spawn-agent researcher
```

#### 3. 發送命令

```bash
# 從任何地方發送命令到指定 window
just send-cmd agent-1 "pwd"
just send-cmd agent-2 "echo 'Hello Agent 2'"
just send-cmd commander "just list-agents"
```

#### 4. 列出所有 Agents

```bash
just list-agents
```

#### 5. 清理工作區

```bash
just cleanup
```

---

## 🤖 AI Agent API (適合 Claude Code 和其他 AI Agents)

**重要！** 如果你是 AI Agent（如 Claude Code），使用 `agent-api` 命令可以更容易地自動化 agent 控制流程。

### 為什麼需要 agent-api？

- ✅ **AI-friendly interface** - 清晰的命令結構和錯誤處理
- ✅ **程式化控制** - 適合自動化腳本和 AI 決策
- ✅ **可靠的反饋** - 明確的 exit codes 和錯誤訊息
- ✅ **狀態檢查** - 驗證 agents 是否成功創建

### agent-api 命令

```bash
# 初始化 workspace
agent-api init

# 列出所有 agents
agent-api list

# 啟動新 agent
agent-api spawn researcher

# 發送命令到 agent
agent-api send agent-1 "pwd"

# 檢查 agent 狀態
agent-api status agent-1

# 🚀 並行啟動多個 agents
agent-api parallel-spawn agent-2,agent-3,agent-4

# 🚀 並行發送命令到多個 agents
agent-api parallel-send agent-1,agent-2,agent-3 "echo 'Hello everyone'"

# 查看幫助
agent-api help
```

### AI Agent 使用範例

**範例 1: Claude Code 自動創建協作 agents**

```bash
# Claude Code 可以執行：
agent-api init                          # 初始化
agent-api spawn researcher              # 創建研究員
agent-api spawn developer               # 創建開發者
agent-api send researcher "research X"  # 分配任務
agent-api send developer "implement X"  # 分配任務
```

**範例 2: 並行執行 - 高效多 Agent 協作** 🚀

```bash
# 一次創建整個團隊（比逐個創建快 3-5 倍！）
agent-api parallel-spawn agent-2,agent-3,agent-4,agent-5
# 輸出：🔄 [1/4] Spawning 'agent-2'...
#       🔄 [2/4] Spawning 'agent-3'...
#       🔄 [3/4] Spawning 'agent-4'...
#       🔄 [4/4] Spawning 'agent-5'...
#       ✅ Parallel spawn complete (4 agents created)

# 同時向所有 agents 發送相同的初始指令
agent-api parallel-send agent-1,agent-2,agent-3 "pwd && ls -la"
# 所有 agents 幾乎同時收到並執行命令！

# 分配並行任務
agent-api parallel-send agent-1,agent-2 "run-tests"
agent-api parallel-send agent-3,agent-4 "review-code"
# agent-1,2 執行測試；agent-3,4 執行審查 - 同時進行！
```

**範例 3: 驗證和錯誤處理**

```bash
# AI 可以檢查執行結果
if agent-api send agent-1 "test command"; then
    echo "Command sent successfully"
else
    echo "Failed to send command"
fi

# 檢查 agent 是否存在
agent-api status agent-2
# Exit code 0 = agent exists
# Exit code 1 = agent not found
```

### just vs agent-api

| 特性 | just | agent-api |
|------|------|-----------|
| **目標使用者** | 人類 | AI Agents |
| **輸出格式** | 友善訊息 + emoji | 結構化訊息 |
| **錯誤處理** | 說明性 | 明確 exit codes |
| **互動性** | 可附加 tmux session | 純命令式 |
| **適用場景** | 手動操作 | 自動化腳本 |

**建議：**
- 🧑‍💻 **人類使用** → `just` 命令
- 🤖 **AI 使用** → `agent-api` 命令

## 💡 使用場景

### 場景 1: 並行開發

```bash
# Window 1 (commander)
just send-cmd agent-1 "claude-code implement authentication"
just send-cmd agent-2 "claude-code write tests for authentication"
just send-cmd agent-3 "claude-code review code"
```

### 場景 2: 研究 + 實作

```bash
# Agent-1 研究，Agent-2 實作
just send-cmd agent-1 "claude-code research best practices for REST APIs"
just send-cmd agent-2 "claude-code implement API based on agent-1 research"
```

### 場景 3: 代碼審查循環

```bash
# 開發 → 審查 → 修正
just send-cmd agent-1 "claude-code implement feature"
just send-cmd agent-2 "claude-code review feature"
just send-cmd agent-1 "claude-code fix issues from review"
```

## 🎹 tmux 快捷鍵

在 tmux session 中：

| 快捷鍵 | 說明 |
|--------|------|
| `Ctrl+b w` | 顯示所有 windows |
| `Ctrl+b 0-9` | 切換到指定 window |
| `Ctrl+b ,` | 重新命名當前 window |
| `Ctrl+b n` | 下一個 window |
| `Ctrl+b p` | 上一個 window |
| `Ctrl+b d` | 分離 session（後台運行） |
| `Ctrl+b [` | 進入 scroll mode |
| `Ctrl+b ]` | 粘貼 buffer |

## 📁 專案結構

```
agent-space/
├── .github/                    # GitHub 配置
│   ├── ISSUE_TEMPLATE/         # Issue 模板
│   └── pull_request_template.md
├── bin/                        # 可執行腳本
│   └── start-agent.sh
├── config/                     # 配置檔案
│   └── agents.yaml
├── docs/                       # 文檔
│   ├── ARCHITECTURE.md         # 系統架構
│   ├── LEARNING.md             # 學習筆記
│   └── ROADMAP.md              # 開發路線圖
├── logs/                       # 日誌目錄
├── justfile                    # 任務運行器
├── test-orchestration.sh       # 測試腳本
├── README.md                   # 專案說明
├── CONTRIBUTING.md             # 貢獻指南
└── LICENSE                     # MIT 授權
```

## 🧪 測試

```bash
# 執行測試套件
./test-orchestration.sh

# 預期輸出：✅ All tests passed
```

## 📖 文檔

- **[系統架構](docs/ARCHITECTURE.md)** - 技術架構和設計決策
- **[開發筆記](docs/LEARNING.md)** - Agent Orchestration 探索記錄
- **[開發路線](docs/ROADMAP.md)** - Phase 規劃和時間表
- **[貢獻指南](CONTRIBUTING.md)** - 如何貢獻程式碼

## 🛣️ 開發路線

### ✅ Phase 1: 基礎設施 (已完成)

- [x] tmux session 管理
- [x] 基礎命令發送
- [x] justfile 任務定義
- [x] 測試腳本

### 🚧 Phase 2: Agent 配置系統 (進行中)

- [ ] YAML 配置解析
- [ ] Agent 定義載入
- [ ] 角色和技能分配

詳細規劃：[docs/ROADMAP.md](docs/ROADMAP.md)

## 🤝 貢獻

歡迎各種形式的貢獻！

1. Fork 專案
2. 建立功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交變更 (`git commit -m 'feat: add amazing feature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 建立 Pull Request

詳細指南：[CONTRIBUTING.md](CONTRIBUTING.md)

## 📝 授權

MIT License - 詳見 [LICENSE](LICENSE) 檔案

## 👤 作者

**Pukpuk**

- GitHub: [@pukpuklouis](https://github.com/pukpuklouis)

## 🙏 致謝

- [tmux](https://github.com/tmux/tmux) - 強大的 terminal multiplexer
- [just](https://github.com/casey/just) - 美妙的 command runner
- [Claude Code](https://docs.anthropic.com/claude-code) - AI 輔助開發工具

## 💬 討論

- [GitHub Issues](../../issues) - Bug 報告和功能建議
- [GitHub Discussions](../../discussions) - 一般討論和問題

---

<div align="center">

**🚀 Built with ❤️ for exploring Agent Orchestration**

**⭐ 如果這個專案對你有幫助，請給個 Star！**

</div>
