# folio v0.0.1 — Gap-Closing Implementation Plan

> Companion to `IMPLEMENTATION-PLAN.md` and `SCHEMA-MAP.md`. The original plan landed at ~90% — this document closes the remaining 10%. Architecture is unchanged. Work is purely additive: one feature integration, one label family, two justfile targets, fifteen new fixture files.

---

## 0. Executive Summary

The first plan executed cleanly: schema, pipeline, refs, components, and tests all align with the architecture. Five gaps remain, ordered by risk: (1) `gantty` integration is the only behavioral gap — the gantt component renders tables instead of a visual chart. (2) `compliance-label` is missing from refs. (3) Justfile lacks two CI targets. (4) Fourteen standalone component fixtures are missing from `examples/components/`. (5) The integration showcase `examples/full-standards.typ` does not exist. This plan delivers all five in four phases; phase A is a spike, phases B–D are mechanical.

---

## 1. Context & Constraints

**What's done (verified against `IMPLEMENTATION-PLAN.md`):**
- 30/30 schema paths in `src/core/schema.typ`
- 28/28 pipeline entries in `src/core/pipeline.typ`
- 10/11 label families in `src/core/refs.typ` (compliance missing)
- All 14 new component functions implemented with cross-references
- Backward-compat shape detection for `budget` and `gantt`
- 3 test fixtures in `tests/` exercising cross-refs, formatters, and new sections
- `lib.typ` exports complete

**What's left:**
- `gantty` not declared in `typst.toml`; gantt component renders nested data as tables, not a visual chart
- `compliance-label` + `link-to-compliance` not in `refs.typ`
- Justfile missing `test-full` and `test-components` targets
- 14 missing fixtures in `examples/components/`
- 1 missing fixture: `examples/full-standards.typ`

**Out of scope (still):** computed rollups, i18n, `project.sponsor` / `code` / `version`, breaking the old gantt shape.

[ASSUMPTION] `gantty:0.5.1` API matches what was used in the user's `01` project. The drawer pattern (`default-*-drawer.with(...)`) is the integration surface.
[ASSUMPTION] Existing tests/fixtures continue to pass with no changes after each phase.

---

## 2. Architecture Overview

No engine changes. The expansion in this plan touches:

```
typst.toml                    [+1 dependency declaration]
src/core/refs.typ             [+1 label family + 1 link function]
src/components/planning.typ   [gantt() rewrite — drawer construction + gantty call]
                              [+ compliance() emits compliance-label]
src/lib.typ                   [+2 exports: compliance-label, link-to-compliance]
examples/components/*.typ     [+14 new fixtures]
examples/full-standards.typ   [+1 new integration fixture]
justfile                      [+2 targets]
```

Everything else stays untouched. The pipeline, phase orchestrators, schema, audit, state, theme, primitives, and all other components remain exactly as they are.

---

## 3. Design Patterns & Code Standards

### Pattern: Token-to-Drawer Adapter (new, internal to `gantt()`)

- **What it is:** A pure function `build-gantty-drawer(st)` that reads folio's resolved tokens (palette, typography, geometry) and returns the dict shape `gantty.gantt` expects under its `drawer:` argument. The drawer is rebuilt on every render via `context` so brand overrides propagate.
- **Why this pattern:** It isolates the `gantty`-shaped quirks (drawer dicts, `default-*-drawer.with(...)` calls) from folio's token system. The `gantt` component remains a thin wrapper: read state, build drawer, call `gantty.gantt`. If `gantty`'s drawer API changes, only this adapter changes — folio's tokens don't move.
- **At year 3:** Adding a new theme variant (dark mode, high-contrast) is a token change, not a gantty change.
- **At year 10:** If folio replaces `gantty` with another charting library (or builds its own), the swap touches only `build-gantty-drawer` and the import line. The `gantt` component signature and the data shape don't change.

### Standards reaffirmed
- The `gantt` component keeps its shape detection: flat array → table fallback (backward compat); dict → visual via `gantty`.
- Drawer construction lives **inside** `planning.typ` as a private `let`, not exported from `lib.typ`.
- `compliance-label` and `link-to-compliance` follow the exact pattern of the other 10 label families. No new abstraction.

---

## 4. Component Map & Directory Structure

### New / modified files

| Path | Status | Responsibility |
|---|---|---|
| `typst.toml` | Modified | Declare `gantty:0.5.1` as a package dependency |
| `src/core/refs.typ` | Modified | Add `compliance-label`, `link-to-compliance` |
| `src/components/planning.typ` | Modified | Rewrite `gantt()` with gantty drawer integration; add `compliance-label` emission to `compliance()` |
| `src/lib.typ` | Modified | Export `compliance-label`, `link-to-compliance` |
| `justfile` | Modified | Add `test-full` and `test-components` targets |
| `examples/components/success-criteria.typ` | New | Standalone fixture |
| `examples/components/stakeholders.typ` | New | Standalone fixture |
| `examples/components/assumptions-log.typ` | New | Standalone fixture |
| `examples/components/requirements.typ` | New | Standalone fixture |
| `examples/components/quality.typ` | New | Standalone fixture |
| `examples/components/communication.typ` | New | Standalone fixture |
| `examples/components/risk-strategy.typ` | New | Standalone fixture |
| `examples/components/compliance.typ` | New | Standalone fixture |
| `examples/components/decision-log.typ` | New | Standalone fixture |
| `examples/components/deliverables-register.typ` | New | Standalone fixture |
| `examples/components/acceptance.typ` | New | Standalone fixture |
| `examples/components/benefits-review.typ` | New | Standalone fixture |
| `examples/components/handover.typ` | New | Standalone fixture |
| `examples/components/financial-closure.typ` | New | Standalone fixture |
| `examples/full-standards.typ` | New | Integration showcase using all 28 sections |

### Standalone fixture pattern (applies to all 14 new fixtures)

Each fixture is the minimum viable consumer of one component. Same pattern as `examples/components/budget.typ` etc.:
- Imports the component function and `folio-init` from `@local/folio:0.0.1`
- Wraps with `folio-init` carrying just enough data to render
- Calls the component with its data path
- Closes with a one-sentence rationale describing what the fixture demonstrates

The fixtures are **not** test files. They are documented usage examples and serve as compile-canaries: if a component's signature drifts, its fixture stops compiling.

---

## 5. Trade-off Analysis

```
DECISION: Where to construct the gantty drawer
OPTIONS CONSIDERED:
  A. Inline in gantt() — build the drawer dict every call, in the component body.
     + Local. No new symbols. Easy to read in one place.
     − gantt() becomes long (60+ lines of drawer config).
  B. Private helper in planning.typ — `let build-gantty-drawer(st) = (...)`.
     + Component body stays short. Adapter is testable in isolation.
     − One more name in the file.
  C. Separate module src/theme/gantty-adapter.typ.
     + Cleanly isolated. Theme-adjacent.
     − Premature for one consumer. Folio doesn't have other charting libs to share with.
CHOSEN: B
REASON: Keeps gantt() readable, isolates gantty quirks, but doesn't over-engineer. If a second
charting integration appears, promote to C without changing call sites.
REVISIT IF: A second external chart library is added, or build-gantty-drawer exceeds 100 lines.
```

```
DECISION: Drawer style mapping — token paths used for gantty
OPTIONS CONSIDERED:
  A. Reuse existing tokens directly — palette.primary for bars, palette.intent.warning for milestones, etc.
     + No new tokens. Brand overrides Just Work.
     − Some gantty surfaces (sidebar, headers, dividers) don't have obvious folio token equivalents.
  B. Add gantt-specific token namespace — palette.gantt.bar, palette.gantt.milestone, etc.
     + Explicit. Each gantty surface has a named token.
     − Pollutes the token namespace. Brand overrides need to know about gantt-specific paths.
CHOSEN: A
REASON: Reuse is the right default. Map gantty surfaces to existing tokens:
  - Phase headers / sidebar dividers → palette.primary (and lighter variants via .lighten())
  - Sub-task bars → palette.intent.neutral.lighten(40%) with palette.primary stroke
  - Milestones → palette.intent.warning
  - Gridlines → palette.surface.border
A consumer who wants gantt-specific brand control already has the lever via brand override of palette.primary.
REVISIT IF: Multiple consumers report wanting gantt-only color overrides without affecting the rest of the doc.
```

```
DECISION: Standalone fixtures — stub data or realistic data?
OPTIONS CONSIDERED:
  A. Minimum stubs — single-row arrays, "Demo Foo" strings, no cross-refs.
     + Tiny files. Fast to compile. Pattern-matches existing fixtures.
     − Doesn't show cross-refs working in isolation.
  B. Realistic data with self-contained cross-refs — e.g., success-criteria fixture includes
     an objective with the same OBJ-1 ID so the link resolves.
     + Demonstrates cross-references working.
     − Requires more data per fixture; some sections need data from multiple paths.
CHOSEN: A for sections without cross-refs, B for sections with cross-refs
REASON: A fixture's job is to render the component. Cross-refs that don't resolve produce orphan
warnings, which are diagnostic noise in a fixture. For sections that emit OR follow cross-refs
(success-criteria, assumptions-log, acceptance, benefits-review, deliverables-register, compliance,
quality), include the referenced entity inline so links resolve. For others (handover,
financial-closure, communication, risk-strategy), stubs are fine.
REVISIT IF: A consumer reports a fixture that compiles but doesn't demonstrate the component's
intended use.
```

---

## 6. Phased Implementation Plan

### Phase A — Foundational refs + justfile

**Goal:** Close the trivial gaps so later phases don't trip over them. Add the missing label family and the missing CI targets.

**Components to modify:**
- `src/core/refs.typ` — add `compliance-label(id) = label("compliance-" + slugify(id))` and `link-to-compliance(id) = safe-link(compliance-label(id), id)`.
- `src/components/planning.typ` — `compliance()` emits `compliance-label(id)` on each row's ID cell (mirrors the pattern in `requirements()`, `decision-log()`, etc.).
- `src/lib.typ` — export `compliance-label`, `link-to-compliance` in the refs section.
- `justfile` — add two targets: `test-full` (compile only `examples/full-standards.typ`) and `test-components` (compile every file under `examples/components/`).

**Dependencies:** None.

**Exit criteria:**
```bash
# Existing tests still compile
just compile

# New justfile targets exist (will fail because target files don't exist yet — that's expected for now)
just --list | rg 'test-full|test-components'

# refs.typ has 11 label families
rg '^#let .+-label\(id\)' src/core/refs.typ | wc -l   # → 11

# lib.typ exports the new symbols
rg 'compliance-label|link-to-compliance' src/lib.typ   # → 2 hits
```

**Risk flags:** None. Trivial additions following established patterns.

---

### Phase B — gantty integration

**Goal:** The behavioral gap. Make the visual Gantt render via `gantty`, themed via folio tokens, when the data is in the new nested shape. Old flat shape continues to render as a table (already works).

**Components to modify:**
- `typst.toml` — add `gantty` to dependencies. [ASSUMPTION] The Typst package manifest format accepts a `[dependencies]` block or equivalent; verify against the current Typst spec before declaring.
- `src/components/planning.typ`:
  - Add `#import "@preview/gantty:0.5.1": gantt as gantty-render, sidebar, header, task, dividers, milestones, dependencies, field` (exact symbol list to match `01`'s usage).
  - Add private helper `let build-gantty-drawer(st) = (...)` — constructs the drawer dict from folio tokens.
  - Rewrite the dict branch of `gantt()` to: extract `start`, `end`, `tasks`, `milestones` from the data; call `gantty-render((start: ..., end: ..., tasks: ..., milestones: ...), drawer: build-gantty-drawer(st))`.
  - Keep the array branch unchanged (backward compat fallback).

**Drawer mapping spec (token paths):**
- Sidebar phase labels → `palette.primary`, weight bold, size from `typography.size.md`.
- Sidebar subtask labels → `palette.intent.neutral`, size from `typography.size.sm`.
- Sidebar dividers → `palette.primary` (phase) and `palette.surface.border` (subtask).
- Month/day header strokes → `palette.primary` (month) and `palette.primary.lighten(60%)` (day) with gridlines from `palette.surface.border`, dotted, thin.
- Phase task bars → `palette.primary` fill, `palette.primary.darken(20%)` stroke, width from a fixed pt value (e.g. 16pt) since tokens don't have a "bar height" yet.
- Subtask bars → `palette.primary.lighten(40%)` fill, `palette.primary` stroke, width 10pt.
- Milestones → `palette.intent.warning` stroke, thickness 2pt.

**Dependencies:** Phase A complete (mostly for justfile so `just compile` includes everything cleanly).

**Exit criteria:**
```bash
# typst.toml declares the dependency
rg 'gantty' typst.toml

# project-01-audit (which has nested gantt data) compiles AND renders a visual chart
just local
typst compile examples/project-01-audit.typ
# Visual inspection: gantt section shows phase bars, day headers, milestone markers, themed colors

# Cross-refs test (which uses nested gantt) compiles
typst compile tests/cross-refs.typ

# Backward compat: a fixture with the old flat array shape still renders as a table
# (Use any older test or write a one-shot)
echo '#import "@local/folio:0.0.1": gantt, folio-init
#show: body => folio-init(data: (baselines: (schedule: (gantt: ((id: "T1", name: "Old Shape", start: "2026-01-01", end: "2026-02-01", progress: "50%"),)))), body)
#gantt("baselines.schedule.gantt")' > /tmp/test-old-gantt.typ
typst compile /tmp/test-old-gantt.typ

# Brand override changes gantty colors
echo '#import "@local/folio:0.0.1": project-doc
#show: project-doc(
  data: (project: (name: "Brand Test"), baselines: (schedule: (gantt: (start: "2026-01-01", end: "2026-03-01", tasks: ((name: "P1", subtasks: ((id: "T1", name: "Task", start: "2026-01-01", end: "2026-02-01"),))))))),
  brand: (palette: (primary: rgb("#dc2626")))
)' > /tmp/test-brand-gantt.typ
typst compile /tmp/test-brand-gantt.typ
# Visual inspection: bars and headers are red, not blue
```

**Risk flags:**
- [HIGH] gantty's drawer API surface. The drawer dict shape must match `gantty:0.5.1` exactly. The `01` project's working code is the reference — copy its import list and drawer structure verbatim, then replace hardcoded colors with `resolve-token` calls.
- [MEDIUM] `typst.toml` dependency declaration syntax. Verify against the current Typst package spec; the format may be `[dependencies]` table, `dependencies = [...]`, or import-only (resolved at compile time from the `@preview` namespace). If `gantty` is consumed via `@preview` and Typst auto-resolves, no `typst.toml` change is needed beyond the import statement.
- [LOW] Theme override propagation. Because `build-gantty-drawer(st)` runs inside a `context` block that reads `folio-state`, brand overrides should flow through automatically. Verify with the brand-override test above.

---

### Phase C — Standalone component fixtures (×14)

**Goal:** Round out `examples/components/` with one fixture per new component. Each fixture is short (≈10–25 lines) and follows the established pattern.

**Files to create (all under `examples/components/`):**

| File | Imports | Data shape | Cross-refs included? |
|---|---|---|---|
| `success-criteria.typ` | `success-criteria, folio-init` | objectives + success_criteria | yes (objective_id) |
| `stakeholders.typ` | `stakeholders, folio-init` | stakeholders only | no |
| `assumptions-log.typ` | `assumptions-log, folio-init` | assumptions + risk_register | yes (risk_id) |
| `requirements.typ` | `requirements, folio-init` | requirements (multi-category) | no (emits labels only) |
| `quality.typ` | `quality, folio-init` | quality + requirements | yes (req_id in criteria) |
| `communication.typ` | `communication, folio-init` | communication only | no |
| `risk-strategy.typ` | `risk-strategy, folio-init` | risk_strategy only | no |
| `compliance.typ` | `compliance, folio-init` | compliance + requirements | yes (req_ids) |
| `decision-log.typ` | `decision-log, folio-init` | decision_log + risk_register + issue_log | yes (prompted_by_*) |
| `deliverables-register.typ` | `deliverables-register, folio-init` | deliverables + requirements | yes (req_ids) |
| `acceptance.typ` | `acceptance, folio-init` | acceptance + deliverables_register | yes (deliverable_id) |
| `benefits-review.typ` | `benefits-review, folio-init` | benefits_review + objectives | yes (objective_id) |
| `handover.typ` | `handover, folio-init` | handover only | no |
| `financial-closure.typ` | `financial-closure, folio-init` | financial_closure only | no |

For fixtures with cross-refs included, the referenced entity must use the same ID the link points to. Without this, every fixture compile produces an orphan warning — pollutes the diagnostic baseline.

**Dependencies:** Phase A (compliance-label exists, lib.typ exports it). Phase B is **not** required — the gantt fixture already exists from the original implementation.

**Exit criteria:**
```bash
# All component fixtures compile
just test-components
# (or directly: fd -e typ . examples/components/ -x typst compile {})

# Each new fixture produces a one-page PDF
fd -e typ . examples/components/ -x typst compile {} && \
  fd -e pdf . examples/components/ | wc -l   # → 14 + (existing count)

# No orphan refs in the cross-ref-bearing fixtures
# (Compile each and visually verify the orphan section in the audit dashboard, if used)
```

**Risk flags:**
- [LOW] Cross-ref correctness. Each fixture must internally satisfy its own links. The audit checklist in the exit criteria catches this.

---

### Phase D — Full-standards integration showcase

**Goal:** Build the "this is what folio can do at full coverage" fixture. One file, one data dict, all 28 sections rendered, all cross-references resolving, audit dashboard reporting all 30 paths as Present.

**Files to create:**
- `examples/full-standards.typ` — consumer file. Uses `project-doc` with `config: (audit: true, toc: true)`. Imports a data dict from a sibling file.
- `examples/data-full.typ` — exhaustive data dict covering every schema path with consistent IDs across cross-references (every `req_id` in budget points to a real `REQ-XX`; every `objective_id` in success_criteria and benefits_review points to a real `OBJ-X`; every `deliverable_id` in acceptance points to a real `D-X`; etc.).

**Data design rules (for `data-full.typ`):**
- 3–5 objectives, all referenced by at least one success criterion and at least one benefits-review entry.
- 5–8 requirements, each referenced by at least one budget line item and at least one deliverable.
- 2–3 milestones, at least one referenced by a risk and at least one by an issue.
- 3–4 risks, at least one with `source_assumption` pointing to a real assumption.
- 2–3 issues, at least one with `blocks_deliverable`.
- 2–3 deliverables, all referenced by at least one acceptance entry.
- 1–2 compliance entries with `req_ids` pointing to real requirements.
- All other sections populated with realistic but minimal data.

**Dependencies:** Phase A, Phase B, Phase C all complete.

**Exit criteria:**
```bash
# The integration fixture compiles
just test-full
# (or: typst compile examples/full-standards.typ)

# Full regression — every example and every test compiles
just test

# Visual inspection of full-standards.pdf:
#   - All 28 sections render with data (no missing placeholders in main doc body)
#   - Audit dashboard at top shows all 30 paths as Present
#   - Orphan References section at the bottom shows "No orphan references detected"
#   - Visual gantt renders with phase bars, milestones, themed colors
#   - Budget renders with category subtotals + extra costs (percentage-based) + grand total
#   - All cross-reference links are clickable (manual click test in PDF reader)
```

**Risk flags:**
- [MEDIUM] Data consistency at scale. With ~20+ cross-references, one mismatched ID produces an orphan. Iterate: compile, check orphans section, fix, recompile.

---

## 7. Implementation Management

### Sequencing

```
Phase A (refs + justfile)        [foundational, no deps]
    │
    ├──► Phase B (gantty)        [needs A only for justfile completeness]
    │
    └──► Phase C (14 fixtures)   [needs A for compliance-label]
              │
              ▼
         Phase D (full-standards) [needs A, B, C]
```

Phase B and Phase C are parallelizable after Phase A. Recommend completing B first because its risk is highest — landing the spike unblocks any uncertainty that would otherwise propagate into C and D.

### Critical path

A → B → D. Phase C can slip a day without affecting D's start, since D's data dict is the gating work, not the fixtures.

### Breaking changes

None. All work is additive. Backward compat for the gantt component is preserved via shape detection (already implemented).

### Integration points

- `gantty:0.5.1` API surface. If the imported symbol names differ from `01`'s usage (`default-tasks-drawer`, etc.), the spike in Phase B catches this on the first compile.
- `typst.toml` dependency declaration. Verify the current Typst spec before declaring; if `@preview` packages are auto-resolved, no manifest change is needed.

---

## 8. Validation & Testing Strategy

### Test surfaces

| Layer | Test Type | Verifies | How |
|---|---|---|---|
| refs.typ | Compile + grep | `compliance-label` exists and exports | `rg 'compliance-label' src/{core/refs,lib}.typ` returns hits in both |
| gantt component | Compile + visual | Visual chart renders for nested data | `typst compile tests/cross-refs.typ`, inspect PDF |
| gantt backward compat | Compile + visual | Old flat shape still renders as table | Manual fixture in `/tmp` |
| Brand propagation | Compile + visual | gantty drawer reflects brand override | `/tmp/test-brand-gantt.typ` |
| Component fixtures | Compile | All 14 new fixtures produce PDFs | `just test-components` |
| Integration | Compile + visual | All 28 sections render, all xrefs resolve, no orphans | `just test-full` + audit dashboard inspection |
| Full regression | Compile | Nothing broke | `just test` |

### Per-phase exit gates

Each phase has a self-contained `Exit criteria` block above with exact commands. A phase is not done until every command in its block returns success and (where applicable) visual inspection of the rendered PDF matches expectations.

### CLI command index

```bash
just compile           # All examples + tests compile (existing)
just test              # Clean + compile + list, removes PDFs after (existing)
just test-components   # All examples/components/ fixtures compile (NEW)
just test-full         # examples/full-standards.typ compiles (NEW)
just local             # Sync src/ to ~/.local/share/typst/packages/local/folio/0.0.1 (existing)
```

### Architecture fitness functions (re-asserted)

- No upward imports: `rg 'import.*phases' src/components/` → empty.
- No cross-component imports: `rg 'import.*components/' src/components/` → only self-references within each phase file.
- Schema/pipeline alignment: every entry in `schema.typ` (excluding pure meta paths) has a matching pipeline entry. Verified by inspection.

---

## 9. Open Questions & Risks

1. **Typst dependency declaration syntax.** Confirm whether `gantty:0.5.1` requires an explicit `typst.toml` entry or is auto-resolved via the `@preview` namespace. If auto-resolved, the Phase B `typst.toml` change reduces to a no-op or a comment.

2. **gantty drawer API stability.** `01`'s `gantt.typ` is the working reference. If `gantty` releases a 0.6+ with breaking drawer changes, `build-gantty-drawer` must track. Pin to `0.5.1` explicitly to defer.

3. **Bar height in tokens.** The current token system has no "bar height" or "row height" path. Phase B uses fixed pt values (16pt for phase bars, 10pt for subtasks). [REVISIT] in v0.1.0 — add `geometry.gantt.bar-height` and similar if multiple consumers want this control.

4. **Orphan policy for compliance entries.** Phase A adds `compliance-label` emission, but no other entity in the cross-ref graph currently links *to* a compliance entry. The label is forward-looking — once `requirements` or `risk_register` gain a `compliance_id` reference (post-v0.0.1), the link infrastructure is ready. Until then, compliance-label is a no-op cost.

5. **Visual regression baseline.** PDFs aren't pixel-snapshotted. Visual changes to the gantt chart between v0.0.1 patches will not be caught automatically. [REVISIT] when a snapshot tool for Typst PDFs becomes practical.