# 更新指南

## 插件（URL 方式）

Claude Code 会自动管理 URL 方式安装的插件。重启 Claude Code 即可获取更新。

---

## Skill

只更新内置文件（`_` 开头），用户自定义内容不会被覆盖：

```bash
git clone https://github.com/kingkongshot/Pensieve.git /tmp/pensieve

# 内置 pipelines
cp /tmp/pensieve/skill/pipelines/_*.md .claude/skills/pensieve/pipelines/

# 内置 maxims
cp /tmp/pensieve/skill/maxims/_*.md .claude/skills/pensieve/maxims/

# 脚本和模板
cp -r /tmp/pensieve/skill/scripts .claude/skills/pensieve/
cp /tmp/pensieve/skill/loop/*.template.md .claude/skills/pensieve/loop/
cp /tmp/pensieve/skill/loop/README.md .claude/skills/pensieve/loop/
cp /tmp/pensieve/skill/SKILL.md .claude/skills/pensieve/

rm -rf /tmp/pensieve
```

---

## 更新后

重启 Claude Code，说 `loop` 验证更新成功。

---

## 保留的用户内容

更新时以下内容不会被覆盖：

| 目录 | 保留内容 |
|------|----------|
| `pipelines/` | 非 `_` 开头的文件 |
| `maxims/` | `custom.md` |
| `decisions/` | 所有文件 |
| `knowledge/` | 所有文件 |
| `loop/` | 历史 loop 目录 |
