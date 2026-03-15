# Shared Rules

## Root Rules

1. `.src/` 是系统文件目录（位于 skill 根目录）；不要把用户数据或运行时状态写进去。
2. `.pensieve/.state/` 是隐藏运行时状态目录；报告、marker、缓存等脏数据写这里。
3. `.pensieve/{maxims,decisions,knowledge,pipelines}` 是用户数据目录；除此之外，只有 `.pensieve/state.md` 可以被维护脚本重写。
4. skill 根目录的 `SKILL.md` 是静态、tracked 文件——不要修改它。
5. 先确认再执行。用户没明确要求时，不自动跑长流程。
6. 先读规范再写数据：写 maxim/decision/knowledge/pipeline 前先读 `.src/references/` 里的对应规范。
7. 链接保持连通：`decision/pipeline` 至少一条 `[[...]]` 链接。

## Path conventions

- 系统 skill 根目录：`~/.claude/skills/pensieve/`
- 工具规范：`.src/tools/*.md`
- 执行脚本：`.src/scripts/*.sh`
- 隐藏模板：`.src/templates/**`
- 项目用户数据：`<project>/.pensieve/`
- 隐藏运行时状态：`<project>/.pensieve/.state/**`
- 用户数据：
  - `.pensieve/maxims/*.md`
  - `.pensieve/decisions/*.md`
  - `.pensieve/knowledge/*/content.md`
  - `.pensieve/pipelines/run-when-*.md`

## Semantic layers

- `knowledge` = IS (facts)
- `decision` = WANT (trade-offs)
- `maxim` = MUST (hard rules)
- `pipeline` = HOW (processes)

## When to use migrate / upgrade

- Old paths, key file drift, legacy graph remnants: `migrate`
- Updating skill source code or refreshing installation: `upgrade`
