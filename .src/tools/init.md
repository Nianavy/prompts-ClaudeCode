---
description: 初始化当前项目的 .pensieve/ 用户数据目录并补齐种子文件，执行基线探索与代码审查，产出可沉淀候选。幂等，不覆盖已有用户数据。
---

# Init Tool

> Tool boundaries: see `.src/references/tool-boundaries.md` | Shared rules: see `.src/references/shared-rules.md`

## Use when

- 首次在项目中接入 Pensieve
- 用户需要安装后初始化或重装后补齐默认结构
- 缺少基础目录：`<project>/.pensieve/{maxims,decisions,knowledge,pipelines}`
- 缺少默认 pipeline 或 taste-review 知识

如果用户先问"怎么安装/重装 Pensieve"，先读 `.src/references/skill-lifecycle.md`，再执行本工具。

## Failure fallback

- `.src/scripts/init-project-data.sh` missing: stop and report skill installation is incomplete
- Init script fails: output the failure reason, stop subsequent actions

## Standard execution

> All `.src/` paths below are relative to the skill root (`$PENSIEVE_SKILL_ROOT`, typically `~/.claude/skills/pensieve/`).

```bash
bash "${PENSIEVE_SKILL_ROOT:-$HOME/.claude/skills/pensieve}/.src/scripts/init-project-data.sh"
```

Then:

1. 读取 `<project>/.pensieve/pipelines/run-when-reviewing-code.md`
2. 基于最近提交与热点文件做一次探索
3. 产出"可沉淀候选清单"，但不自动写入
4. 最后提醒用户手动跑 doctor：

```bash
bash "${PENSIEVE_SKILL_ROOT:-$HOME/.claude/skills/pensieve}/.src/scripts/run-doctor.sh" --strict
```
