---
id: run-when-committing
type: pipeline
title: Commit Pipeline
status: active
created: 2026-02-28
updated: 2026-02-28
tags: [pensieve, pipeline, commit, self-improve]
name: run-when-committing
description: Mandatory commit-stage pipeline. First determine whether there are insights worth capturing; if so, run self-improve to capture them, then perform atomic commits. Trigger words: commit, git commit.

stages: [tasks]
gate: auto
---

# Commit Pipeline

Before committing, automatically extract insights from the session context + diff and capture them, then perform atomic commits. No user confirmation is requested at any point.

**Self-improve reference**: `.src/tools/self-improve.md`

**Context Links (at least one)**:
- Based on: [[knowledge/taste-review/content]]
- Related: none

---

## Signal Judgment Rules

The value of capturing insights lies in reuse next time; unsubstantiated guesses will mislead future decisions.

- 只沉淀"可复用且有证据"的洞察；无法验证的猜测不落库。
- 分类遵守语义分层：IS → `knowledge`，WANT → `decision`，MUST → `maxim`。
- 用语义而非"knowledge 优先"来分配，因为错误分类会导致约束力度不匹配（本该是 MUST 的写成了 knowledge，后续容易被忽略）。

---

## Task Blueprint (create tasks in order)

### Task 1: Decide whether to capture -- determine if there are insights worth capturing

**Goal**: Quickly determine whether this commit contains experience worth capturing; skip to Task 3 if not

**Read inputs**:
1. `git diff --cached` (staged changes)
2. Current session context

**Steps**:
1. Run `git diff --cached --stat` to understand the scope of changes
2. Review the current session, checking for any of the following signals (any match triggers capture):
   - Identified a bug root cause (debugging session)
   - Made an architectural or design decision (considered multiple approaches)
   - Discovered a new pattern or anti-pattern
   - Exploration produced a "symptom -> root cause -> location" mapping
   - Clarified boundaries, ownership, or constraints
   - Discovered a capability that does not exist / has been deprecated in the system
3. If none of the above signals are present (purely mechanical changes: formatting, renaming, dependency upgrades, simple fixes), mark "skip capture" and jump directly to Task 3

**Completion criteria**: Clear determination of "capture needed" or "skip capture", with a one-line rationale

---

### Task 2: Auto-capture -- extract insights and write them

**Goal**: Extract insights from session context + diff, write to user data, without asking the user

**Read inputs**:
1. Task 1 determination result (if "skip", skip this Task)
2. `git diff --cached`
3. Current session context
4. `.src/tools/self-improve.md`

**执行步骤**：
1. 读取 `self-improve.md`，按其 Phase 1（提取与分类）+ Phase 2（读取规范+写入）执行
2. 从会话中提取核心洞察（可以是多条）
3. 为每条洞察先判定语义层并分类（IS->knowledge, WANT->decision, MUST->maxim；必要时可多层同时落地）
4. 读取 `.src/references/` 中目标类型的规范，按规范生成内容
5. 类型特定要求：
   - `decision`：包含"探索减负三项"（下次少问/少查/失效条件）
   - 探索型 `knowledge`：包含（状态转换 / 症状→根因→定位 / 边界与所有权 / 反模式 / 验证信号）
   - `pipeline`：需满足条件（重复出现 + 不可交换 + 可验证）
6. 写入目标路径，补关联链接
7. 刷新 Pensieve 项目状态：
   ```
   bash "$PENSIEVE_SKILL_ROOT/.src/scripts/maintain-project-state.sh" --event self-improve --note "auto-improve: {files}"
   ```
8. Output a brief summary (write path + capture type)

**DO NOT**: Do not ask user for confirmation, do not show drafts awaiting approval, write directly

**完成标准**：洞察已写入用户数据（或明确无需沉淀），`state.md` 与 `.state/pensieve-user-data-graph.md` 已刷新

---

### Task 3: Atomic commits

**Goal**: Perform atomic git commits

**Read inputs**:
1. `git diff --cached`
2. User's commit intent (commit message or context)

**Steps**:
1. Analyze staged changes, cluster by reason for change
2. If multiple independent change groups exist, commit each separately (one atomic commit per group)
3. Commit message conventions:
   - Title: imperative mood, <50 characters, specific
   - Body: explain "why" not "what"
4. Execute `git commit`

**Completion criteria**: All staged changes have been committed, each commit is independent and revertible

---

## Failure Fallback

1. `git diff --cached` 为空：跳过 Task 2/Task 3，输出"无 staged 变更，不提交"。
2. 沉淀步骤失败：记录阻塞原因并跳过沉淀，继续 Task 3；结尾追加"建议运行 `doctor`"。
3. `state.md` 维护失败：保留已沉淀内容，报告失败命令与重试建议，不回滚已写入文件。
