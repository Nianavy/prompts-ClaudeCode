---
description: 只读扫描当前项目的 .pensieve/ 用户数据目录，检查 frontmatter、链接、目录结构、关键种子文件与 auto memory 对齐情况，输出固定格式报告。
---

# Doctor Tool

> Tool boundaries: see `.src/references/tool-boundaries.md` | Shared rules: see `.src/references/shared-rules.md` | Directory conventions: see `.src/references/directory-layout.md`

## Use when

- Post-initialization verification
- Post-upgrade verification
- Confirming MUST_FIX count is zero after migration
- Suspected drift in graph, frontmatter, directory structure, or memory pointers

## Standard execution

> All `.src/` paths below are relative to the skill root (`$PENSIEVE_SKILL_ROOT`, typically `~/.claude/skills/pensieve/`).

```bash
bash "${PENSIEVE_SKILL_ROOT:-$HOME/.claude/skills/pensieve}/.src/scripts/run-doctor.sh" --strict
```

Doctor only maintains:

- `<project>/.pensieve/state.md`（生命周期状态 + Graph）
- 运行时图谱输出如 `.pensieve/.state/pensieve-user-data-graph.md`
- Claude auto memory `~/.claude/projects/<project>/memory/MEMORY.md`

It will not modify your business code.
