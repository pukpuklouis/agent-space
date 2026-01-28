# 貢獻指南

感謝您對 Agent Workspace 專案的興趣！這是一個開源實驗專案，歡迎各形式的貢獻。

## 🎯 專案目標

這個專案專注於：
- 建立實用的 agent orchestration 系統
- 探索 multi-agent 協作模式
- 整合 AI 工具進入開發工作流

## 🚀 如何貢獻

### 報告問題

如果您發現 bug 或有功能建議：

1. 檢查 [Issues](../../issues) 是否已有相關討論
2. 如果沒有，建立新的 Issue 並使用提供的模板
3. 清楚描述問題或建議

### 提交程式碼

1. **Fork** 這個 repository
2. 建立您的功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交您的變更 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 建立 Pull Request

### 開發流程

```bash
# 1. 複製專案
git clone https://github.com/pukpuklouis/agent-space.git
cd agent-space

# 2. 建立分支
git checkout -b feature/your-feature-name

# 3. 測試您的變更
./test-orchestration.sh

# 4. 提交變更
git add .
git commit -m "feat: add your feature description"

# 5. 推送並建立 PR
git push origin feature/your-feature-name
```

## 📋 開發規範

### Commit 訊息格式

我們遵循 [Conventional Commits](https://www.conventionalcommits.org/)：

```
<type>: <description>

[optional body]

[optional footer]
```

**Types:**
- `feat`: 新功能
- `fix`: 修復 bug
- `docs`: 文檔更新
- `style`: 程式碼格式（不影響功能）
- `refactor`: 重構
- `test`: 測試相關
- `chore`: 構建或輔助工具變更

**範例：**
```bash
git commit -m "feat: add agent configuration validation"
git commit -m "fix: correct tmux session naming logic"
git commit -m "docs: update README with new workflow examples"
```

### 程式碼風格

- **Shell Script**: 遵循 [ShellCheck](https://www.shellcheck.net/) 建議
- **YAML**: 使用 2 空格縮排
- **文檔**: 清晰、簡潔的中文說明

### 測試要求

所有變更必須通過現有測試：

```bash
./test-orchestration.sh
```

新增功能應包含相應的測試案例。

## 🎓 技術資源

這個專案涉及的技術：

- [tmux Documentation](https://github.com/tmux/tmux/wiki)
- [Just Command Runner](https://just.systems/)
- [Claude Code Documentation](https://docs.anthropic.com/claude-code)
- [YAML Specification](https://yaml.org/spec/)

## 📞 聯絡方式

- 專案 Issues: [GitHub Issues](../../issues)
- Discussions: [GitHub Discussions](../../discussions)

## 🙏 致謝

感謝所有貢獻者讓這個學習專案更加完善！

---

** happy coding! 🚀**
