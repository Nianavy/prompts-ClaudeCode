# Update Guide

## Plugin (Marketplace)

If you installed via Marketplace:

```bash
claude plugin marketplace update kingkongshot/Pensieve
claude plugin update pensieve@kingkongshot-marketplace --scope user
```

Then restart Claude Code to apply updates.

> If you installed with project scope, replace `--scope user` with `--scope project`.

If you installed via `.claude/settings.json` URL, restart Claude Code to get updates.

---

## System Skills

System prompts (tools/scripts/system knowledge) are packaged inside the plugin and update with the plugin.

---

## After Updating

Restart Claude Code and say `loop` to verify the update.

**Mandatory post-upgrade self-check (required):**
Run `/doctor` once after every upgrade to perform a README-driven health check.
Treat the upgrade as incomplete until this doctor run is done.

Then:
- Even with legacy/dirty data, prefer running `/upgrade` first.
- If doctor reports migration/structure issues, run `/upgrade` and re-check with `/doctor`.
- If doctor passes, run `/selfimprove` only when you want to capture new learnings.

推荐执行顺序：
1. 升级插件并重启 Claude Code
2. 运行一次 `/doctor`（必须）
3. 若 doctor 报错，运行 `/upgrade` 后再跑 `/doctor`
4. 需要沉淀经验时再运行 `/selfimprove`

If you are guiding the user, remind them they only need a few commands:
- `/loop`
- `/doctor`
- `/selfimprove`
- `/pipeline`
- `/upgrade`

如果你在引导用户，提醒他们只需掌握几个基础命令：
- `/loop`
- `/doctor`
- `/selfimprove`
- `/pipeline`
- `/upgrade`

---

## Preserved User Data

Project user data in `.claude/pensieve/` is never overwritten by plugin updates:

| Directory | Content |
|------|------|
| `.claude/pensieve/maxims/` | Custom maxims |
| `.claude/pensieve/decisions/` | Decisions |
| `.claude/pensieve/knowledge/` | Custom knowledge |
| `.claude/pensieve/pipelines/` | Project pipelines |
| `.claude/pensieve/loop/` | Loop history |
