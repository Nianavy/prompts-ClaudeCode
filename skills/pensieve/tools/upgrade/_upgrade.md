---
description: 版本升级与旧版本清理。仅做版本对比、拉取最新、清理遗留；不做前置体检。升级完成后引导用户手动运行 doctor。
---

# 升级工具

> 工具边界见 `<SYSTEM_SKILL_ROOT>/references/tool-boundaries.md` | 共享规则见 `<SYSTEM_SKILL_ROOT>/references/shared-rules.md`

## Tool Contract

### Use when
- 用户要求升级 Pensieve
- 用户要求清理旧版本残留
- 用户要求确认升级前后版本变化

### Failure fallback
- `claude` 命令不可用：停止并返回安装/环境问题
- 版本拉取失败：返回失败日志路径，停止后续动作
- 迁移冲突：输出 `*.migrated.*` 文件列表，要求人工合并

## 执行原则（简化后）
1. **以脚本结果为准**：`run-upgrade.sh` 的 summary/report 是唯一事实源，不做人工推断。
2. **不做升级前结构检查**：upgrade 阶段不运行 doctor，不输出 PASS/FAIL。
3. **升级只做三件事**：版本比对、拉取最新、清理老版本残留（含旧路径/旧键/旧插件名）。
4. **doctor 后置**：升级完成后只引导用户手动运行 doctor。

## 标准执行

```bash
bash <SYSTEM_SKILL_ROOT>/tools/upgrade/scripts/run-upgrade.sh
```

可选：仅预演不落盘

```bash
bash <SYSTEM_SKILL_ROOT>/tools/upgrade/scripts/run-upgrade.sh --dry-run
```

## 输出要求

升级完成后必须输出：
- 升级前版本与升级后版本
- 是否发生版本变化
- 清理与迁移统计
- 报告与摘要文件路径
- 明确下一步命令（手动运行 doctor）：

```bash
bash <SYSTEM_SKILL_ROOT>/tools/doctor/scripts/run-doctor.sh --strict
```

## 约束
- Upgrade 不得在执行中调用 doctor
- Upgrade 不得输出 doctor 分级结论（PASS/PASS_WITH_WARNINGS/FAIL）
- 允许维护项目级 `SKILL.md` 与 auto memory 引导块
