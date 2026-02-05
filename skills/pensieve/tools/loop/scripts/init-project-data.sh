#!/bin/bash
# Initialize project-level pensieve user data directory:
#   <project>/.claude/pensieve/
#
# This directory is user-owned and is NEVER overwritten by plugin updates.
#
# Safe to run multiple times (idempotent).

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
DATA_ROOT="$PROJECT_ROOT/.claude/pensieve"

mkdir -p "$DATA_ROOT"/{maxims,decisions,knowledge,loop,pipelines}

CUSTOM_MAXIMS="$DATA_ROOT/maxims/custom.md"
if [[ ! -f "$CUSTOM_MAXIMS" ]]; then
  cat > "$CUSTOM_MAXIMS" << 'EOF'
# 项目级准则（可修改）

以下为安装时写入的初始准则，你可以自由修改或替换：

1. "好品味"(Good Taste) - 你的第一准则 "有时你可以从不同角度看问题，重写它让特殊情况消失，变成正常情况。"
经典案例：链表删除操作，10行带if判断优化为4行无条件分支
充分相信上游数据，如果缺失数据则应该在上游提供而不是打补丁
好品味是一种直觉，需要经验积累
消除边界情况永远优于增加条件判断

2. "Never break userspace" - 你的铁律 "我们不破坏用户可见行为！"
任何会意外导致用户可见行为改变的代码都是bug，无论多么"理论正确"
内核的职责是服务用户，而不是教育用户
需求以外的用户可见行为不变是神圣不可侵犯的

3. 实用主义 - 你的信仰 "我是个该死的实用主义者。"
经典案例：删除10行fallback逻辑直接抛出错误，让上游数据问题在测试中暴露而不是被掩盖
解决实际问题，而不是假想的威胁
主动直接的暴露问题，假想了太多边界情况，但实际一开始它就不该存在
拒绝微内核等"理论完美"但实际复杂的方案
代码要为现实服务，不是为论文服务

4. 简洁执念 - 你的标准 "如果你需要超过3层缩进，你就已经完蛋了，应该修复你的程序。"
经典案例：290行巨型函数拆分为4个单一职责函数，主函数变为10行组装逻辑
函数必须短小精悍，只做一件事并做好
不要写兼容、回退、临时、备用、特定模式生效的代码
代码即文档，命名服务于阅读
复杂性是万恶之源
默认不写注释，除非需要详细解释这么写是为什么
EOF
fi

README="$DATA_ROOT/README.md"
if [[ ! -f "$README" ]]; then
  cat > "$README" << 'EOF'
# .claude/pensieve（用户数据）

这个目录是项目级的 Pensieve 用户数据区：
- **永不**由插件更新覆盖
- 适合提交到仓库（团队共享），也可以按需忽略

## 结构

- `maxims/`：你的准则（建议维护 `custom.md`）
- `decisions/`：决策记录（按 `<SYSTEM_SKILL_ROOT>/decisions/README.md` 的格式）
- `knowledge/`：外部知识（按 `<SYSTEM_SKILL_ROOT>/knowledge/README.md` 的格式）
- `loop/`：Loop 运行目录（每次 loop 一个子目录）
  - `pipelines/`：项目级自定义流程（安装时写入初始 pipeline）
EOF
fi

REVIEW_PIPELINE="$DATA_ROOT/pipelines/review.md"
if [[ ! -f "$REVIEW_PIPELINE" ]]; then
  cat > "$REVIEW_PIPELINE" << 'EOF'
---
name: review
description: |
  代码审查 pipeline。基于 Linus Torvalds 好品味哲学、John Ousterhout 设计原则、Google Code Review 标准。

  Use this pipeline when:
  - 用户请求代码审查
  - 用户说"review"、"审查"、"检查代码"
  - 需要评估代码质量或设计决策

  Examples:
  <example>
  用户: "帮我 review 这段代码"
  -> 触发此 pipeline
  </example>
  <example>
  用户: "检查一下这个 PR"
  -> 触发此 pipeline
  </example>

signals: ["review", "审查", "检查代码", "代码质量", "code review"]
stages: [tasks]
gate: auto
---

# Code Review Pipeline

基于三大来源的代码审查流程。

**核心铁律**：
1. 消除特殊情况永远优于增加条件判断
2. **Never break userspace** - 用户可见行为不变是神圣不可侵犯的
3. 快速暴露问题，不要用 fallback 掩盖上游 bug
4. 复杂性是万恶之源

**知识参考**：`<SYSTEM_SKILL_ROOT>/knowledge/taste-review/content.md`

---

## Phase 0: 前置思考

在开始分析前，先问自己四个问题：

| 问题 | 判断 |
|------|------|
| 这是真问题还是臆想？ | 拒绝过度设计，解决实际问题 |
| 有更简单的方法吗？ | 永远寻找最简方案 |
| 会破坏什么吗？ | Never break userspace |
| 有完全不同的方案吗？ | Design It Twice |

---

## Phase 1: 思考维度

选择相关维度进行分析：

### 数据结构分析
> "Bad programmers worry about the code. Good programmers worry about data structures."

- 核心数据是什么？关系如何？
- 数据流向哪里？谁拥有它？
- **能否通过改变数据结构来简化代码？**

### 特殊情况识别
> "好代码没有特殊情况"

- 找出所有 if/else 分支
- 哪些是业务逻辑？哪些是糟糕设计的补丁？
- **能否重新设计来消除这些分支？**

### 复杂度审查
> "如果实现需要超过3层缩进，重新设计它"

- 这个功能的本质是什么？（一句话说清）
- 当前方案用了多少概念？能减半吗？

### 破坏性分析
> "Never break userspace"

- 哪些现有功能可能受影响？
- 用户可见行为是否保持不变？

---

## Phase 2: 8 步审查

### Step 1: 确定范围

```markdown
## Step 1: 审查范围
- **类型**: [文件 / Git 提交 / 代码片段]
- **代码量**: [X 行] [WARNING 如果 >200 行]
- **主要变更**: [一句话]
```

### Step 2: 设计审查

检查：代码归属、库选择、模块划分、Design It Twice

```markdown
## Step 2: 设计审查
**结论**: [PASS / WARNING / CRITICAL]
- 是否考虑过替代方案：[是/否]
```

### Step 3: 复杂性审查

检查：变更放大、认知负荷、未知的未知、模块深度

```markdown
## Step 3: 复杂性审查
**结论**: [PASS / WARNING / CRITICAL]
- **变更放大**: [是/否]
- **认知负荷**: [低/中/高]
- **模块深度**: [深/正常/浅]
```

### Step 4: 代码结构审查

检查：嵌套层次（<=2好, =3警告, >3禁止）、函数长度（<50好, >100禁止）、局部变量（<=5好, >10禁止）

```markdown
## Step 4: 代码结构审查
**结论**: [PASS / WARNING / CRITICAL]
- **最深嵌套**: [X 层]
- **最长函数**: [Y 行]
- **特殊情况数**: [N 处]
```

### Step 5: 命名与注释审查

检查：名称精确性、注释是否解释"为什么"

```markdown
## Step 5: 命名与注释审查
**结论**: [PASS / WARNING / CRITICAL]
```

### Step 6: 异常处理审查

检查：防御性默认值、fallback 代码、异常聚合

```markdown
## Step 6: 异常处理审查
**结论**: [PASS / WARNING / CRITICAL]
- **防御性代码**: [有/无]
- **Fallback 代码**: [有/无]
```

### Step 7: 破坏性分析

检查：受影响功能、用户可见行为变化

```markdown
## Step 7: 破坏性分析
**结论**: [PASS / WARNING / CRITICAL]
- **用户可见行为变化**: [有/无]
```

### Step 8: 测试审查

检查：测试覆盖、测试有效性

```markdown
## Step 8: 测试审查
**结论**: [PASS / WARNING / CRITICAL]
```

---

## Phase 3: 综合评定

```markdown
## 综合评定

### 品味评分
[好品味 / 凑合 / 垃圾]

### 步骤汇总
| 步骤 | 结论 |
|------|------|
| 设计 | [PASS/WARNING/CRITICAL] |
| 复杂性 | [PASS/WARNING/CRITICAL] |
| 代码结构 | [PASS/WARNING/CRITICAL] |
| 命名注释 | [PASS/WARNING/CRITICAL] |
| 异常处理 | [PASS/WARNING/CRITICAL] |
| 破坏性 | [PASS/WARNING/CRITICAL] |
| 测试 | [PASS/WARNING/CRITICAL] |

### 致命问题
[最严重的 1-3 个问题，引用代码位置]

### 改进建议
- 当前：[代码片段]
- 建议：[重写代码片段]
```
EOF
fi

echo "✅ 初始化完成: $DATA_ROOT"
echo "  - maxims/custom.md: $([[ -f "$CUSTOM_MAXIMS" ]] && echo exists || echo created)"
