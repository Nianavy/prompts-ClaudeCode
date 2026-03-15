<div align="center">

# Pensieve

**A continuously growing project memory for AI agents.**

[![GitHub Stars](https://img.shields.io/github/stars/kingkongshot/Pensieve?color=ffcb47&labelColor=black&style=flat-square)](https://github.com/kingkongshot/Pensieve/stargazers)
[![License](https://img.shields.io/badge/license-MIT-white?labelColor=black&style=flat-square)](LICENSE)

[中文 README](https://github.com/kingkongshot/Pensieve/blob/zh/README.md)

</div>

## Without Pensieve vs With Pensieve

| Without | With |
|---|---|
| Re-explain project conventions every time | Conventions stored as maxims, loaded automatically |
| Code review standards depend on mood | Review standards codified as executable pipelines |
| Repeat last week's mistakes this week | Lessons learned are captured automatically, skipped next time |
| Forget the reasoning behind a design three months later | Decisions record context and alternatives |
| Re-read docs to locate module boundaries every time | Knowledge caches exploration results for direct reuse |

## 安装

Prerequisites: `git`, `bash`, `Python 3.8+`.

> **多客户端说明**：下文以 Claude Code 路径 `~/.claude/skills/pensieve` 为例。其他客户端请替换为对应路径：
> | 客户端 | 安装路径 |
> |--------|----------|
> | Claude Code | `~/.claude/skills/pensieve` |
> | Cursor | `~/.cursor/skills/pensieve` |
> | 通用 Agent | `~/.agents/skills/pensieve` |

```bash
# 1. 全局安装系统代码（只需一次，所有项目共享）
git clone -b zh https://github.com/kingkongshot/Pensieve.git ~/.claude/skills/pensieve

# 2. 安装全局 hooks（仅 Claude Code，只需一次）
#    其他客户端跳过此步——hooks 是 Claude Code 专属功能
bash ~/.claude/skills/pensieve/.src/scripts/install-hooks.sh

# 3. 在你的项目中初始化用户数据
cd <your-project>
bash ~/.claude/skills/pensieve/.src/scripts/init-project-data.sh
```

系统代码全局唯一安装在 `~/.claude/skills/pensieve/`，用户数据按项目存储在 `<project>/.pensieve/`。十个项目共享同一份系统代码，各自维护独立的项目知识。

### AI agent 自动安装参考

当用户要求 AI agent 安装 Pensieve 时，agent 应按以下决策流程执行：

**第一步：检查全局安装状态**

```bash
# 检查是否已安装
if [[ -d ~/.claude/skills/pensieve/.src ]]; then
    echo "Pensieve 已全局安装，跳过 clone"
else
    # 检查 ~/.claude 是否是 git 仓库（某些用户用 git 同步 ~/.claude 配置）
    if git -C ~/.claude rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        # ~/.claude 是 git 仓库，使用 submodule 安装
        git -C ~/.claude submodule add -b zh https://github.com/kingkongshot/Pensieve.git skills/pensieve
    else
        git clone -b zh https://github.com/kingkongshot/Pensieve.git ~/.claude/skills/pensieve
    fi
    # hooks 是 Claude Code 专属功能，其他客户端跳过此步
    bash ~/.claude/skills/pensieve/.src/scripts/install-hooks.sh
fi
```

**第二步：判断是否执行项目初始化**

```bash
# 如果当前目录就是 ~/.claude，不要自动初始化项目数据
# （除非用户明确说明把 ~/.claude 本身当作项目开发）
CURRENT_DIR="$(pwd)"
CLAUDE_DIR="$(cd ~/.claude 2>/dev/null && pwd)"
if [[ "$CURRENT_DIR" == "$CLAUDE_DIR" ]]; then
    echo "当前目录是 ~/.claude，跳过项目初始化。如需在此目录使用 Pensieve，请明确告知。"
    exit 0
fi
```

**第三步：检查旧版本数据并初始化**

```bash
# 检查当前项目是否有旧版本用户数据
# 判定标准：legacy 目录下存在 maxims/decisions/knowledge/pipelines 子目录
# 注意：在 ~/.claude 下，skills/pensieve 是 v2 安装位置，但如果其中包含
# 用户数据子目录（maxims/ 等），说明是 v1 项目级安装残留，仍需迁移
HAS_LEGACY=0
for legacy_dir in .claude/skills/pensieve .agents/skills/pensieve skills/pensieve .claude/pensieve; do
    if [[ -d "$legacy_dir" ]] && [[ -d "$legacy_dir/maxims" || -d "$legacy_dir/decisions" || -d "$legacy_dir/knowledge" || -d "$legacy_dir/pipelines" ]]; then
        HAS_LEGACY=1
        break
    fi
done

if [[ "$HAS_LEGACY" -eq 1 ]]; then
    # 发现旧版本数据——询问用户是否迁移
    echo "检测到旧版本 Pensieve 用户数据，是否迁移到 v2？"
    # 用户确认后执行：
    bash ~/.claude/skills/pensieve/.src/scripts/init-project-data.sh
    bash ~/.claude/skills/pensieve/.src/scripts/run-migrate.sh
    bash ~/.claude/skills/pensieve/.src/scripts/run-doctor.sh --strict
elif [[ -d .pensieve ]]; then
    echo "当前项目已初始化 Pensieve"
else
    bash ~/.claude/skills/pensieve/.src/scripts/init-project-data.sh
fi
```

> **要点总结**：先检查全局安装 → 判断 `~/.claude` 是否 git 仓库决定 clone/submodule → 跳过 `~/.claude` 目录的项目初始化 → 检测旧数据决定 init/migrate。

## Updating

```bash
# 更新系统代码（一次操作，所有项目生效）
cd ~/.claude/skills/pensieve
git pull --ff-only || { git fetch origin && git reset --hard "origin/$(git rev-parse --abbrev-ref HEAD)"; }

# 在项目中健康检查（可选但推荐）
cd <your-project>
bash ~/.claude/skills/pensieve/.src/scripts/run-doctor.sh --strict
```

`git pull --ff-only` 适用于正常更新。如果远程分支被 force push（如 squash 后重新发布），ff-only 会失败，此时 `fetch + reset` 会将本地同步到远程最新状态。这是安全的——skill 目录只包含 tracked 系统文件，用户数据在 `<project>/.pensieve/`，不会被覆盖。

For complete installation, update, reinstall, and uninstall instructions, see [skill-lifecycle.md](.src/references/skill-lifecycle.md).

## 从旧版本升级

如果你的 Pensieve 是项目级安装（代码在 `<project>/.claude/skills/pensieve/`），或通过 `claude plugin install` 安装，需要迁移到 v2 架构：

```bash
# 1. 全局安装系统代码（如果尚未安装）
if [[ ! -d ~/.claude/skills/pensieve ]]; then
    # 检查 ~/.claude 是否是 git 仓库
    if git -C ~/.claude rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        git -C ~/.claude submodule add -b zh https://github.com/kingkongshot/Pensieve.git skills/pensieve
    else
        git clone -b zh https://github.com/kingkongshot/Pensieve.git ~/.claude/skills/pensieve
    fi
fi

# 2. 安装全局 hooks（仅 Claude Code）
#    其他客户端跳过此步——hooks 是 Claude Code 专属功能
bash ~/.claude/skills/pensieve/.src/scripts/install-hooks.sh

# 3. 在每个项目中执行迁移
cd <your-project>
bash ~/.claude/skills/pensieve/.src/scripts/init-project-data.sh
bash ~/.claude/skills/pensieve/.src/scripts/run-migrate.sh
bash ~/.claude/skills/pensieve/.src/scripts/run-doctor.sh --strict

# 4. 卸载旧插件（如有）
claude plugin uninstall pensieve 2>/dev/null || true
```

`run-migrate.sh` 会自动将用户数据（`maxims/`、`decisions/`、`knowledge/`、`pipelines/`）从旧路径移入 `<project>/.pensieve/`，运行时状态从 `<project>/.state/` 移入 `<project>/.pensieve/.state/`，清理旧 graph 文件和 README 副本，然后删除旧版本目录。

## 自增强循环

You don't need to maintain the knowledge base manually — everyday development feeds it automatically:

```
    Develop --> Commit --> Review (pipeline)
     ^                      |
     |   <-- auto-capture <-|
     |                      v
     +-- maxim / decision / knowledge / pipeline
```

- **编辑时**：PostToolUse hook 在 Write/Edit 后自动同步 state.md 知识图谱（Claude Code 专属，其他客户端需手动触发 `self-improve`）
- **审查时**：按项目 pipeline 执行，结论回流为 knowledge
- **复盘时**：主动要求沉淀，洞察写入对应层

You just write code — the knowledge base grows on its own.

## Four-Layer Knowledge Model

| Layer | Type | What it answers | Cross-project? |
|---|---|---|---|
| **MUST** | maxim | What must never be violated? | Yes — holds across projects and languages |
| **WANT** | decision | Why was this approach chosen? | No — deliberate trade-offs for the current project |
| **HOW** | pipeline | How should this process run? | Depends |
| **IS** | knowledge | What are the current facts? | No — verifiable system facts |

Layers are connected through three types of semantic links: `based-on / leads-to / related`.

For detailed specifications, see [maxims.md](.src/references/maxims.md), [decisions.md](.src/references/decisions.md), [knowledge.md](.src/references/knowledge.md), and [pipelines.md](.src/references/pipelines.md) under `.src/references/`.

## Five Tools

| Tool | What it does | Trigger example |
|---|---|---|
| `init` | 创建数据目录，种子化默认内容 | "帮我初始化 pensieve" |
| `upgrade` | 刷新 skill 源码 | "升级 pensieve" |
| `migrate` | 迁移旧版本数据，对齐种子文件 | "迁移到 v2" |
| `doctor` | 只读扫描，检查结构和格式 | "检查数据有没有问题" |
| `self-improve` | 从对话和 diff 中提取洞察，写入四层知识 | "把这次经验沉淀下来" |

For tool boundaries and redirect rules, see [tool-boundaries.md](.src/references/tool-boundaries.md).

<details>
<summary><b>Architecture Details</b></summary>

### Directory Structure

```text
~/.claude/skills/pensieve/          # 用户级（全局唯一安装）
├── SKILL.md                        #   静态路由文件（tracked）
├── .src/                           #   系统代码、模板、参考文档、核心引擎
│   ├── core/
│   ├── scripts/
│   ├── templates/
│   ├── references/
│   └── tools/
└── agents/                         #   代理配置

<project>/.pensieve/                # 项目级（每项目独立，可纳入版本控制）
├── maxims/                         #   工程准则
├── decisions/                      #   架构决策
├── knowledge/                      #   缓存的探索结果
├── pipelines/                      #   可复用工作流
├── state.md                        #   动态：生命周期状态 + 知识图谱
└── .state/                         #   运行时产物（gitignored）
```

`.src/manifest.json` is the anchor for the skill root directory — scripts use it to locate all paths.

### Design Principles

- **系统代码与用户数据物理隔离** — 系统代码在 `~/.claude/skills/pensieve/`，用户数据在 `<project>/.pensieve/`，`git pull` 更新系统不可能触碰项目数据
- **规则单一来源** — 目录、关键文件、迁移路径统一由 `.src/core/schema.json` 定义
- **先确认再执行** — 范围不明确时先问，不自动启动长流程
- **先读规范再写数据** — 创建任何用户数据前先读 `.src/references/` 的格式规范

</details>

## About the Linus Prompt

Pensieve was originally known for a Linus Torvalds-style system prompt — using "good taste," "never break userspace," and "simplicity obsession" to constrain agent behavior.

That engineering philosophy is still at the core of Pensieve, but it is no longer an isolated prompt. It is now distributed across executable structures: default maxims define hard rules, taste-review knowledge provides review criteria, and review/commit pipelines put those rules into practice. What was once a one-off prompt has become a continuously effective engineering capability.

## License

MIT
