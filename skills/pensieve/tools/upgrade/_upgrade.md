# 升级工具

---
description: 指导用户数据升级到项目级 `.claude/pensieve/` 目录结构
---

你是升级工具（Upgrade Tool）。你的任务是**说明理想的用户数据目录结构**，并指导如何把旧结构的数据迁移到新结构。你不直接决定用户数据内容，只负责路径和规则。

升级流程遵循一个硬规则：**先清理旧插件命名，再迁移用户数据**。不做旧命名兼容共存。

## 目标结构（项目级，永不被插件覆盖）

```
<project>/.claude/pensieve/
  maxims/      # 用户/团队准则（如 custom.md）
  decisions/   # 决策记录（ADR）
  knowledge/   # 用户补充的资料/参考
  pipelines/   # 项目级自定义 pipelines
  loop/        # loop 运行产物（每次 loop 一个目录）
```

## 迁移原则

- **先清理旧插件标识**：先清理旧安装引用和 `settings.json` 中旧 key，再执行后续迁移。
- **旧插件引用只认定为待清理**：
  - `pensieve@Pensieve`
  - `pensieve@pensieve-claude-plugin`
- **新插件唯一引用**：`pensieve@kingkongshot-marketplace`
- **系统能力在插件内部**：`<SYSTEM_SKILL_ROOT>/` 里的内容随插件更新，不要移动、不要覆盖。
- **旧的系统文件不再需要**：旧目录中属于系统内置的文件无需保留。迁移完成后可删除旧系统文件以避免混淆（仅删除项目内的旧拷贝，不要动插件内部）。
- **用户数据放项目级**：只迁移用户自己写的内容到 `.claude/pensieve/`。
- **不覆盖已有用户数据**：目标位置已有同名文件时，保留原文件，新增时加后缀或提示用户确认。
- **保留结构**：迁移时保持子目录层级与文件名尽量不变。
- **初始内容从模板复制**：初始准则与 pipeline 模板存放在插件内，由升级/初始化时复制到项目级。
- **版本不一致时**：若用户数据与系统版本不一致，**先分别阅读两份内容**，再阅读该目录下 README，并**严格按 README 规范完成合并/迁移**。

## 识别“用户数据”的常见位置（旧结构）

可能存在于：

- 项目仓库内的 `skills/pensieve/` 或其子目录
- 用户手动放置的 `maxims/`、`decisions/`、`knowledge/`、`pipelines/`、`loop/`

### 哪些应迁移

- **用户自定义文件**（非系统内置）：
  - `maxims/custom.md` 或其他非 `_` 前缀文件
  - `decisions/*.md`
  - `knowledge/*`
  - `pipelines/*.md`
  - `loop/*`

> 旧版本曾在插件内置 `maxims/_linus.md` 与 `pipelines/review.md`。如果你仍在使用它们，请将内容复制到：
> - `.claude/pensieve/maxims/custom.md`（准则）
> - `.claude/pensieve/pipelines/review.md`（pipeline）
> 复制后即可删除旧文件，避免后续插件更新覆盖。

### 模板位置（插件内）

- `<SYSTEM_SKILL_ROOT>/tools/upgrade/templates/maxims.initial.md`
- `<SYSTEM_SKILL_ROOT>/tools/upgrade/templates/pipeline.review.md`

### 哪些不迁移

- **系统内置文件**（通常以下划线 `_` 开头）：
  - `pipelines/_*.md`
  - `maxims/_*.md`
  - 系统知识库（插件内置）
  - 旧结构中属于系统的 README/模板/脚本等

## 清理旧系统文件（项目内）

升级完成后，删除旧结构中“系统拷贝”以避免混淆（**仅限项目内旧拷贝**）：

- `<project>/skills/pensieve/`（旧版本把系统能力放进项目的情况）
- `<project>/.claude/skills/pensieve/`（旧版本把 skill 放进项目的情况）
- 旧系统目录中的 `README.md` 与 `_*.md`（下划线开头提示词）

> 若不确定是否为“旧系统拷贝”，先备份再删除。

## 清理旧插件命名（必须先做）

在迁移用户数据前，先检查并清理以下配置文件：

- 用户级：`~/.claude/settings.json`
- 项目级：`<project>/.claude/settings.json`

检查 `enabledPlugins`：

- 删除旧 key：`pensieve@Pensieve`
- 删除旧 key：`pensieve@pensieve-claude-plugin`
- 保留/补齐新 key：`pensieve@kingkongshot-marketplace: true`

如果同时存在多个 key，不要做兼容；应清理到只保留新 key。

## 迁移步骤（建议给大模型执行）

1. 先扫描并检查：
   - `~/.claude/settings.json`
   - `<project>/.claude/settings.json`
2. 清理 `enabledPlugins` 旧 key，仅保留/补齐新 key（见上节）
3. 清理旧安装引用（不做兼容保留）：
   - 卸载 `pensieve@Pensieve`（若存在）
   - 卸载 `pensieve@pensieve-claude-plugin`（若存在）
4. 扫描旧结构中用户自定义内容（按上面的“应迁移”规则）
5. 创建目标目录：
   - `mkdir -p .claude/pensieve/{maxims,decisions,knowledge,pipelines,loop}`
6. **合并准则**：
   - 若 `.claude/pensieve/maxims/custom.md` 不存在 → 从模板复制
   - 若存在且旧准则也存在 → 追加到末尾并标注“迁移内容”
7. **迁移预设 pipeline（必须对内容做合并判断）**：
   - 若 `.claude/pensieve/pipelines/review.md` 不存在 → 从模板复制
   - 若存在 → **读取并对比内容**：
     - 若内容等价 → 跳过
     - 若内容不同 → 生成 `review.migrated.md`，并在 `review.md` 顶部写入合并说明或将差异追加到末尾
8. 将用户文件移动/复制到目标目录（保持相对结构）
9. 若有冲突（同名文件）：
   - **不要直接跳过**，必须先读取并判断是否需要合并
   - 内容相同 → 可跳过
   - 内容不同 → 追加到现有文件并标注“迁移内容”，或生成 `*.migrated.md` 并提示合并
10. 清理旧系统文件（见上方清单）
11. 迁移完成后，输出迁移结果清单（旧路径 → 新路径）

## 插件清理与升级命令（按顺序）

迁移前后都可执行，建议按以下顺序执行：

```bash
# 清理旧安装引用（忽略不存在的情况）
claude plugin uninstall pensieve@Pensieve --scope user || true
claude plugin uninstall pensieve@pensieve-claude-plugin --scope user || true

# 如为 project scope 安装，同步清理 project
claude plugin uninstall pensieve@Pensieve --scope project || true
claude plugin uninstall pensieve@pensieve-claude-plugin --scope project || true

# 更新 marketplace 与新命名插件
claude plugin marketplace update kingkongshot/Pensieve
claude plugin update pensieve@kingkongshot-marketplace --scope user
```

## 约束

- 不要删除系统内置文件
- 不要修改插件内部的系统内容
- 可以修改 settings.json，但仅限 `enabledPlugins` 的 Pensieve 相关键
