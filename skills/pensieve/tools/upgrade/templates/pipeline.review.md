---
name: review
description: |
  代码审查 pipeline。基于 Linus Torvalds 的品味哲学、John Ousterhout 的设计原则与 Google Code Review 标准。

  在以下情况使用此 pipeline：
  - 用户明确要求代码审查
  - 用户说“review”“代码审查”“帮我检查代码”
  - 需要评估代码质量或设计决策

  示例：
  <example>
  User: "帮我 review 这段代码"
  -> 触发此 pipeline
  </example>
  <example>
  User: "检查这个 PR"
  -> 触发此 pipeline
  </example>

signals: ["review", "code review", "check code", "code quality", "代码审查", "审查代码", "检查代码", "代码质量", "review一下"]
stages: [tasks]
gate: auto
---

# 代码审查 Pipeline

这个 pipeline 负责**组织审查流程**。审查标准与深层依据统一放在 Knowledge 中。

**Knowledge 参考**：`<SYSTEM_SKILL_ROOT>/knowledge/taste-review/content.md`

---

## Phase 0：准备

**目标**：明确范围并加载参考基线

**动作**：
1. 确认审查范围（文件 / 提交 / 代码片段）
2. 识别技术语言与约束
3. 加载审查知识库：`knowledge/taste-review/`

**验证**：范围清晰且知识库已加载

---

## Phase 1：审查

**目标**：应用知识库清单并记录证据

**动作**：
1. 对每个文件执行知识库检查清单（不在此重复理论）
2. 按严重级别记录结论：PASS / WARNING / CRITICAL
3. 对每条 WARNING/CRITICAL 给出精确代码位置

**验证**：每个文件都有带证据的结论

---

## Phase 2：报告

**目标**：输出可执行的审查总结

**动作**：
1. 按严重级别汇总关键问题
2. 提供具体修复建议或重写方案
3. 明确指出任何用户可见行为变化

**验证**：报告包含完整发现与可落地建议
