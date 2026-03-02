# Shared Rules

Cross-cutting hard rules for all tools. Each tool file references this document instead of inlining these rules.

## Version Routing (Hard Rule)

`upgrade` is only responsible for version and migration actions, not for project health-check conclusions.

- When "update version / migrate legacy data / clean up old residue / plugin compatibility issue" is mentioned, route to `upgrade`.
- `init` / `doctor` / `self-improve` / `loop` do not require running `upgrade` first.
- Project health checks (PASS/FAIL, MUST_FIX/SHOULD_FIX) are exclusively output by `doctor`.
- After `init` completes, a `doctor` run is mandatory.
- Recommended order (on demand): `upgrade` (version/migration only) → `doctor` (health check) → `self-improve` (capture).

## Confirm Before Executing (Hard Rule)

When the user has not explicitly issued a tool command, confirm with a one-line question before executing. Never auto-run based on a candidate intent.

- Loop Phase 2 context summary must receive user confirmation before entering Phase 3.
- Self-Improve may write directly when explicitly triggered or pipeline-triggered, without additional confirmation.
- Write operations follow each tool file's own rules; no additional global "draft-then-write" restriction is imposed.

## Semantic Link Rules (Hard Rule)

Three link relationship types: `based-on` / `led-to` / `related`.

Association strength requirements:
- `decision`: **at least one valid `[[...]]` link is required**
- `pipeline`: **at least one valid `[[...]]` link is required**
- `knowledge`: links recommended (may be empty)
- `maxim`: source links recommended (may be empty)

Loop output that becomes a `decision` or `pipeline` must have its links filled in before wrap-up.

## Data Boundaries

- **System capability** (updated via plugin): `<SYSTEM_SKILL_ROOT>/` (inside `skills/pensieve/`, plugin-managed)
  - Contains tools / scripts / system knowledge / format READMEs
  - Does not include built-in pipelines / maxims content
- **User data** (project-level, not overwritten by default): `<USER_DATA_ROOT>/` (`<project>/.claude/skills/pensieve/`)
  - Sole exception: `upgrade` may back up then overwrite critical files (`run-when-*.md`, `knowledge/taste-review/content.md`) for content alignment.
  - Full directory structure in `<SYSTEM_SKILL_ROOT>/references/directory-layout.md`

Path conventions (injected by SessionStart hook):
- `<SYSTEM_SKILL_ROOT>` = absolute path to `skills/pensieve/` inside the plugin
- `<USER_DATA_ROOT>` = absolute path to project-level `.claude/skills/pensieve/`

## Spec-First (Read Before Write)

Before creating or checking any type of user data, read the corresponding format spec README:

1. `<SYSTEM_SKILL_ROOT>/maxims/README.md`
2. `<SYSTEM_SKILL_ROOT>/decisions/README.md`
3. `<SYSTEM_SKILL_ROOT>/pipelines/README.md`
4. `<SYSTEM_SKILL_ROOT>/knowledge/README.md`

Constraints:
- Items not explicitly marked `must / required / hard rule / at least one` in the spec must not be flagged as MUST_FIX.
- Limited inference from the spec is allowed but must be labeled as "inferred item".

## Confidence Requirements (Pipeline Output Quality)

Each candidate issue in pipeline output must be tagged with a confidence score (0-100):

| Range | Handling |
|-------|----------|
| >= 80 | Included in final report |
| 50-79 | Labeled "pending verification", not presented as a definitive conclusion |
| < 50 | Discarded |

Only issues with confidence >= 80 are reported as definitive conclusions.
