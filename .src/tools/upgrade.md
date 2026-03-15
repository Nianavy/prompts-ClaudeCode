---
description: 刷新当前 git clone 的 Pensieve skill 源码。优先 git pull --ff-only，远程 force push 时自动回退到 fetch+reset；不做结构迁移与 doctor 分级。
---

# Upgrade Tool

> Tool boundaries: see `.src/references/tool-boundaries.md` | Shared rules: see `.src/references/shared-rules.md`

## Use when

- User requests a Pensieve upgrade
- Need to confirm version changes before and after upgrade

如果用户先问"怎么更新 Pensieve"，先读 `.src/references/skill-lifecycle.md`，再执行本工具。

这个工具只负责全局 skill checkout（`~/.claude/skills/pensieve/`）。
Hooks 通过 `install-hooks.sh` 全局安装，不需要单独更新。

## Standard execution

> All `.src/` paths below are relative to the skill root (`$PENSIEVE_SKILL_ROOT`, typically `~/.claude/skills/pensieve/`).

```bash
bash "${PENSIEVE_SKILL_ROOT:-$HOME/.claude/skills/pensieve}/.src/scripts/run-upgrade.sh"
```

Optional dry-run:

```bash
bash "${PENSIEVE_SKILL_ROOT:-$HOME/.claude/skills/pensieve}/.src/scripts/run-upgrade.sh" --dry-run
```

After upgrade, manually run:

```bash
bash "${PENSIEVE_SKILL_ROOT:-$HOME/.claude/skills/pensieve}/.src/scripts/run-doctor.sh" --strict
```
