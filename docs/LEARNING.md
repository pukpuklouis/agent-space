# Agent Orchestration 開發筆記

本文檔記錄 Agent Workspace 開發過程中的探索、實驗和技術洞察。

## 📚 參考資源

### 推薦閱讀

1. **Multi-Agent Systems**
   - [Multi-Agent Reinforcement Learning](https://www.sciencedirect.com/topics/computer-science/multi-agent-systems/multi-agent-reinforcement-learning)
   - [Multi-Agent Coordination](https://arxiv.org/abs/2102.07249)

2. **Distributed Systems**
   - [Distributed Systems Principles](https://www.distributedsystemsbook.com/)
   - [CAP Theorem](https://www.ibm.com/topics/cap-theorem)

3. **Orchestration Patterns**
   - [Orchestrator Pattern](https://docs.microsoft.com/en-us/azure/architecture/patterns/orchestrator)
   - [Saga Pattern](https://microservices.io/patterns/data/saga.html)

## 🎯 核心概念

### Agent 定義

在本專案中，**Agent** 是指：

> 一個能夠自主執行任務的實體，具有：
> - **Autonomy**: 能獨立做決策
> - **Reactivity**: 能響應環境變化
> - **Proactivity**: 能主動採取行動
> - **Social Ability**: 能與其他 agents 通訊

### Orchestration vs Choreography

| 特性 | Orchestration | Choreography |
|------|---------------|--------------|
| **控制** | 中央控制器 | 分式協調 |
| **複雜度** | 集中管理 | 分散邏輯 |
| **擴展性** | 較低 | 較高 |
| **適用場景** | 簡單流程 | 複雜互動 |
| **我們的選擇** | ✅ Phase 1-3 | 🔮 Phase 4+ |

## 🧪 探索記錄

### 實驗 1: 基礎 Multi-Window 管理

**目標**: 驗證 tmux 是否適合作為 agent workspace

**結果**:
- ✅ tmux 可以輕鬆創建多個 windows
- ✅ 命令發送機制可靠
- ✅ Session 持久化功能優秀

**學習點**:
- `tmux send-keys` 是核心命令
- Session 命名需要避免衝突
- Window 索引從 0 開始

### 實驗 2: YAML 配置

**目標**: 測試 YAML 作為配置格式的可行性

**結果**:
- ✅ YAML 人類可讀性高
- ✅ 支援巢狀結構
- ⚠️ 需要驗證機制避免錯誤配置

**學習點**:
- 使用 `yq` 或 Python 解析 YAML
- 需要 schema 驗證
- 配置熱重載是挑戰

### 實驗 3: Agent 通訊

**目標**: 探索 agent 間通訊的最佳方式

**嘗試過的方法**:
1. **tmux paste-buffer** - 簡單但有限
2. **檔案系統** - 可行但慢
3. **Unix sockets** - 強大但複雜
4. **HTTP API** - 靈活但需要額外服務

**結論**:
- Phase 2-3: 檔案系統 + tmux
- Phase 4+: 考慮 WebSocket 或 gRPC

## 💡 技術洞察

### 1. 極簡主義的價值

我們選擇使用現有工具（tmux + just）而非自己構建：

**優點**:
- 開發速度快
- 穩定性高
- 學習曲線平緩
- 社群支援好

**代價**:
- 功能受限於工具能力
- 整合複雜度增加

### 2. 配置驅動的重要性

從硬編碼到配置驅動的轉變：

**Before**:
```bash
tmux new-window -t $SESSION -n "agent-1"
```

**After**:
```yaml
agents:
  agent-1:
    role: "開發者"
    window: "agent-1"
```

**好處**:
- 非開發者也能配置
- 易於版本控制
- 支援多環境配置

### 3. 漸進式增強

我們採取分階段實現：

```
Phase 1 (MVP) → Phase 2 (配置) → Phase 3 (協作) → Phase 4 (視覺化)
```

每個 Phase 都是可獨立使用的系統。

## 📖 技術筆記

### tmux 關鍵命令

```bash
# Session 管理
tmux new-session -s name          # 創建 session
tmux attach-session -t name       # 附加到 session
tmux kill-session -t name         # 刪除 session
tmux has-session -t name          # 檢查 session 是否存在

# Window 管理
tmux new-window -t session -n name # 創建 window
tmux list-windows -t session      # 列出 windows
tmux send-keys -t session:win cmd # 發送命令

# Layout 管理
tmux select-layout -t session even-horizontal  # 設定 layout
```

### justfile 語法

```makefile
# Recipe 定義
recipe-name:
    echo "Hello"

# 參數化 recipe
greet name:
    echo "Hello {{name}}"

# 內部 recipe（不出現在 --list）
_internal:
    echo "Internal only"

# 變數使用
path := "/some/path"
show-path:
    echo {{path}}

# 條件執行
@if ! condition:
    echo "Condition failed"
```

## 🐛 遇到的問題與解決

### 問題 1: tmux Session 命名衝突

**症狀**: 多個專案使用相同名稱

**解決**:
```bash
SESSION="agent-workspace-$(basename $(pwd))"
```

### 問題 2: Shell Script 中的引號轉義

**症狀**: 命令中的引號被錯誤解析

**解決**:
```bash
just send-cmd target 'echo "Hello"'  # 使用單引號包裹
```

### 問題 3: Window 創建後立即發送命令失敗

**症狀**: 命令在 window 準備好之前發送

**解決**:
```bash
tmux new-window -t $SESSION -n "$NAME"
sleep 0.1  # 短暫等待
tmux send-keys -t $SESSION:"$NAME" "$CMD" C-m
```

## 🔮 未來方向

1. **AI-Native Orchestration**
   - 使用 LLM 進行任務分配
   - 自動化工作流生成
   - 智能錯誤恢復

2. **跨機器 Orchestration**
   - SSH 整合
   - Docker 容器化
   - Kubernetes 原生

3. **視覺化程式設計**
   - 拖拽式 workflow 設計
   - 實時監控 dashboard
   - 效能分析工具

## 📝 開發反思

### 什麼有效

- ✅ **小步快跑**: MVP 快速驗證假設
- ✅ **工具先行**: 使用成熟工具而非重造輪子
- ✅ **文檔同步**: 邊做邊記錄學習筆記

### 什麼可以改進

- ⚠️ **測試覆蓋**: 需要更完整的自動化測試
- ⚠️ **錯誤處理**: 需要更優雅的錯誤訊息
- ⚠️ **配置驗證**: 需要 schema 驗證機制

### 下一步重點

1. 完成 Phase 2 配置系統
2. 探索 agent 間通訊最佳實踐
3. 建立完整測試套件

---

**持續學習，持續改進！** 📚
