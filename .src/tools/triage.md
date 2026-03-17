---
description: 整理 short-term/ 中到期条目：按对应层规范审阅内容质量，达标则 promote 到长期目录，不达标则补齐或删除。
---

# Triage 工具

> 工具边界见 `.src/references/tool-boundaries.md` | 共享规则见 `.src/references/shared-rules.md`

## Use when

- session start 提醒有到期短期记忆
- doctor 报告 `short_term_due_triage`
- 用户请求 "整理短期记忆" / "triage" / "清理 short-term"

## 标准执行

### Step 1：扫描到期条目

1. 扫描 `<project>/.pensieve/short-term/` 下所有 `.md` 文件
2. 解析 frontmatter `created` 日期，筛选到期条目（created + 7天 < today）
3. 跳过 tags 含 `seed` 的文件
4. 若无到期条目，报告"无需整理"并结束
5. 列出到期清单（文件路径 + title + type + 到期天数）

### Step 2：逐条判定（五问决策）

对每个到期条目，依次回答以下五个问题。回答完毕即可得出结论。

#### Q1. 删掉它，未来是否会重复踩坑或重复探索？

> 核心判据：这条知识消失后，有没有人会为同一件事再花时间。

- **是** → 继续 Q2
- **否** → **DELETE**（无复用价值）

#### Q2. 它是否有证据支撑（代码、文档、实验结果、明确的会话上下文）？

> 核心判据：结论是否可追溯，还是仅凭猜测。

- **是** → 继续 Q3
- **否** → **DELETE**（无法验证的猜测会误导决策）

#### Q3. 它是否已被现有长期条目覆盖？

> 检查 `maxims/`、`decisions/`、`knowledge/`、`pipelines/` 中是否已有相同或包含此内容的条目。

- **是** → **DELETE**（重复）
- **否** → 继续 Q4

#### Q4. 写入时的上下文是否仍然成立？

> 核心判据：依赖的技术选型、外部 API、团队结构等是否已变更。

- **是** → 继续 Q5
- **否** → **DELETE**（已过时）

#### Q5. 它是否符合目标层的内容规范？

先读取对应规范：

| type | 规范文件 |
|---|---|
| `maxim` | `.src/references/maxims.md` |
| `decision` | `.src/references/decisions.md` |
| `knowledge` | `.src/references/knowledge.md` |
| `pipeline` | `.src/references/pipelines.md` |

- **达标** → **PROMOTE**
- **不达标但可补齐** → **补齐后 PROMOTE**
- **不达标且不值得补齐** → **DELETE**

#### 判定速查

| Q1 复用 | Q2 证据 | Q3 重复 | Q4 有效 | Q5 达标 | 结论 |
|---|---|---|---|---|---|
| 否 | — | — | — | — | DELETE |
| 是 | 否 | — | — | — | DELETE |
| 是 | 是 | 是 | — | — | DELETE |
| 是 | 是 | 否 | 否 | — | DELETE |
| 是 | 是 | 否 | 是 | 达标 | PROMOTE |
| 是 | 是 | 否 | 是 | 可补齐 | 补齐→PROMOTE |
| 是 | 是 | 否 | 是 | 不值得 | DELETE |

### Step 3：执行决定

- **Promote**：
  - `mv short-term/{type}/file.md {type}/file.md`
  - `status` 改为 `active`
  - 确认 `[[...]]` 链接完整（链接不含 `short-term/` 前缀，无需修改）

- **补齐后 Promote**：
  - 按对应层规范补齐缺失内容
  - 补齐后执行 promote

- **Delete**：
  - 删除文件

### Step 4：刷新状态

> All `.src/` paths below are relative to the skill root (`$PENSIEVE_SKILL_ROOT`, typically `~/.claude/skills/pensieve/`).

```bash
bash "${PENSIEVE_SKILL_ROOT:-$HOME/.claude/skills/pensieve}/.src/scripts/maintain-project-state.sh" --event sync --note "triage: promoted N, deleted M"
```
