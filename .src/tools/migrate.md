---
description: 迁移工具。将旧版本用户数据自动迁移到 v2 目录结构，并对齐关键种子文件；不做版本升级，不给 doctor 分级。
---

# Migrate Tool

> Tool boundaries: see `.src/references/tool-boundaries.md` | Shared rules: see `.src/references/shared-rules.md`

## Use when

- 从 v1（项目级安装）迁移到 v2（用户级系统 + 项目级数据）
- doctor 报告关键文件缺失或 critical file drift
- 需要补齐目录结构或重新对齐种子文件

## Standard execution

> All `.src/` paths below are relative to the skill root (`$PENSIEVE_SKILL_ROOT`, typically `~/.claude/skills/pensieve/`).

```bash
bash "${PENSIEVE_SKILL_ROOT:-$HOME/.claude/skills/pensieve}/.src/scripts/run-migrate.sh"
```

Optional dry-run:

```bash
bash "${PENSIEVE_SKILL_ROOT:-$HOME/.claude/skills/pensieve}/.src/scripts/run-migrate.sh" --dry-run
```
