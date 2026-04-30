# folio v0.0.1 — Architectural Implementation Plan

---

## 0. Executive Summary

folio is a Typst package that turns a single data dictionary into a publication-grade, PMBOK-aligned project management document. This plan expands folio from 14 sections to 28 — covering all four PM phases across PMBOK 7, ISO 21500, and PRINCE2 7 — while adding a cross-referencing system that links requirements to budgets, risks to tasks, deliverables to acceptance records, and objectives to benefits reviews. The architecture is already sound (pipeline-driven orchestration, schema-based audit, token theming, graceful fallbacks). This plan adds data and components without changing the engine. The only new external dependency is `gantty` for visual Gantt rendering.

---

## 1. Context & Constraints

**Project Context:** Existing Typst package, ~57 files, ~26.8k tokens. Modular architecture with clear separation: `core/` (engine), `components/` (section renderers), `phases/` (phase orchestrators), `primitives/` (UI atoms), `theme/` (tokens + resolver), `utils/` (formatters). Nix flake for reproducible dev environment.

**Goals:**
1. Cover the full PM standards skeleton (30 schema paths, 28 pipeline sections)
2. Add ID-based cross-referencing across all referenceable entities
3. Add visual Gantt rendering via `gantty`
4. Enrich budget component with line items, categories, extra costs
5. Add `baselines.requirements` as a new core component
6. Maintain backward compatibility with existing examples
7. Every phase shippable and testable via CLI (`typst compile`)

**Team & Scale:** Solo developer. Package consumers are individuals generating project documents. No server, no API, no concurrency concerns.

**Architectural Rules:**
- Zero-crash guarantee: any data dict compiles, even `(:)`
- Pipeline is the single ordering mechanism
- Public API through `src/lib.typ` only
- Theming via token resolver, never hardcoded colors/sizes
- Cross-references via Typst labels + `safe-link` (orphan-safe)
- `section-guard` controls visibility (auto/true/false)
- No i18n — locale handled via `format-money`, `format-date`, `get-title` overrides

**Out of Scope:**
- Computed rollups (v0.1.0)
- Tailoring / methodology profiles
- i18n locale system
- `project.sponsor`, `project.code`, `project.version`
- Interactive PDF elements
- Importing `01`'s bespoke implementations

[ASSUMPTION] `gantty:0.5.1` API is stable and its input shape won't change before folio ships.
[ASSUMPTION] Typst 0.14.2's conditional `context` blocks and `state` API remain stable.
[ASSUMPTION] All existing examples (`minimal.typ`, `project-01.typ`, `project-01-audit.typ`, `rfp.typ`, `thesis.typ`, and all `components/*.typ`) must compile without modification after each phase.

---

## 2. Architecture Overview

folio's architecture doesn't change. The expansion is purely additive: new components, new pipeline entries, new schema paths, new label families. The engine (orchestrator, pipeline, state, resolve, guard, audit, refs) gets extended but not restructured.

```
┌─────────────────────────────────────────────────────────────────┐
│                        Consumer File                            │
│  #import "@local/folio:0.0.1": project-doc                     │
│  #show: project-doc(data: ..., config: ..., brand: ...)        │
└──────────────────────────────┬──────────────────────────────────┘
                               │
                    ┌──────────▼──────────┐
                    │    orchestrator     │  Reads config, initializes state,
                    │                     │  iterates pipeline, renders phases
                    └──────────┬──────────┘
                               │
              ┌────────────────┼────────────────┐
              │                │                │
    ┌─────────▼──────┐ ┌──────▼───────┐ ┌──────▼───────┐
    │    pipeline     │ │    state     │ │    audit     │
    │  28 records     │ │  data/config │ │  30 paths    │
    │  (phase,id,     │ │  /brand in   │ │  + orphan    │
    │   path,render)  │ │  Typst state │ │  detection   │
    └─────────┬───────┘ └──────────────┘ └──────────────┘
              │
    ┌─────────▼──────────────────────────────────────────┐
    │              Phase Orchestrators (×5)               │
    │  initiation │ planning │ execution │ closure │ custom │
    │  Each filters pipeline by phase, applies            │
    │  section-guard, calls render_fn                      │
    └─────────┬──────────────────────────────────────────┘
              │
    ┌─────────▼──────────────────────────────────────────┐
    │              Components (×28)                       │
    │  Each: reads state → resolves data path →           │
    │  renders via themed UI primitives →                  │
    │  emits labels for cross-references                   │
    └─────────┬──────────────────────────────────────────┘
              │
    ┌─────────▼──────────────────────────────────────────┐
    │              UI Primitives                           │
    │  card │ data-table │ badge │ metric │ progress-bar  │
    │  All themed via resolve-token(st, "path")           │
    └─────────┬──────────────────────────────────────────┘
              │
    ┌─────────▼──────────────────────────────────────────┐
    │              Theme Layer                             │
    │  tokens.typ (defaults) → resolver.typ (brand merge) │
    └────────────────────────────────────────────────────┘
```

**Core domain:** The pipeline + schema + resolve system. This is what makes folio folio — a data dictionary becomes a document via a declarative pipeline.

**Supporting domains:** UI primitives (presentation), theme (styling), refs (cross-linking), audit (diagnostics), formatters (locale).

---

## 3. Design Patterns & Code Standards

### Pattern: Data Pipeline (orchestrator + pipeline + phases)
- **What it is:** A declarative array of records, each mapping `(phase, section_id, data_path, render_fn)`. The orchestrator iterates it; phase files filter by phase; `section-guard` controls visibility.
- **Why:** Decouples section ordering from section rendering. Adding a section is a one-line pipeline entry + a render function. Removing is `config: (sections: (section_id: false))`. Reordering is rearranging the array.
- **At year 3:** New PM standards or custom templates add pipeline entries without touching the engine.
- **At year 10:** The pipeline could be loaded from an external file (YAML, TOML) for fully user-defined document structures.

### Pattern: Resolver Chain (theme/resolver.typ)
- **What it is:** Two-phase lookup: try `brand` dict first, fall back to `default-tokens`. Fail-visible (magenta) if neither has the path.
- **Why:** Brand customization without forking. A consumer overrides `palette.primary` and every component that uses it changes. No prop drilling.
- **At year 3:** Tokens scale linearly — new components just call `resolve-token` with new paths.
- **At year 10:** Could support theme inheritance (base theme → org theme → project theme).

### Pattern: Safe Cross-References (refs.typ)
- **What it is:** Typst labels created from entity IDs via `slugify`. References resolve via `safe-link`: if the target label exists, render a clickable link; if not, record an orphan and render `"ID?"`. Orphans are collected in state and reported in the audit dashboard.
- **Why:** Cross-references in a data-driven document are inherently fragile — the user might reference a risk that doesn't exist yet, or a task they misspelled. Safe-link makes this a diagnostic, not a crash.
- **At year 3:** New entity types (requirements, deliverables, etc.) just register a new label prefix. The pattern scales.
- **At year 10:** Could support bidirectional refs ("this risk is referenced by these issues") via a query pass.

### Pattern: Graceful Degradation (resolve.typ + fallback.typ)
- **What it is:** `resolve(data, path)` traverses the dict. If the path is missing or empty, it returns a `missing("path")` content block — a red-bordered box that says what's absent.
- **Why:** The zero-crash guarantee. A document with `(:)` compiles and shows what's missing. A document with partial data shows what's present and flags the rest.
- **At year 3:** No change needed — the pattern is path-agnostic.
- **At year 10:** Could evolve into a progressive disclosure system where missing sections are hidden by default and shown in "draft mode."

### Standards to Enforce
- **Naming:** snake_case for schema paths and section IDs. kebab-case for Typst function names. Leading underscore for internal helpers.
- **Module boundaries:** Components import from `core/` and `theme/ui.typ` only. Components never import from other components. Phases import from `core/` only.
- **Dependency direction:** `primitives/ ← theme/ui.typ ← components/ ← phases/ ← orchestrator`. Never upward.
- **Error handling:** `resolve()` for data access (never raw `.at()`). `section-guard()` for visibility. `safe-link()` for cross-refs. No panics except for config validation (e.g., duplicate section IDs).

---

## 4. Component Map & Directory Structure

### Proposed Directory Tree (changes marked)

```
folio/
├── README.md
├── MANIFEST.md
├── SCHEMA-MAP.md                          # NEW — this document
├── IMPLEMENTATION-PLAN.md                 # NEW — this document
├── typst.toml                             # MODIFIED — add gantty dependency
├── flake.nix
├── justfile                               # MODIFIED — add new test targets
├── LICENSE
├── docs/
│   └── manual.typ
├── examples/
│   ├── data.typ                           # MODIFIED — expanded to cover all 30 paths
│   ├── minimal.typ                        # UNCHANGED
│   ├── project-01.typ                     # UNCHANGED
│   ├── project-01-audit.typ               # UNCHANGED
│   ├── rfp.typ                            # UNCHANGED
│   ├── thesis.typ                         # UNCHANGED
│   ├── full-standards.typ                 # NEW — fixture that exercises all 28 sections
│   └── components/
│       ├── boundaries.typ                 # UNCHANGED
│       ├── budget.typ                     # MODIFIED — use new rich shape
│       ├── business-case.typ              # UNCHANGED
│       ├── change-log.typ                 # UNCHANGED
│       ├── cover.typ                      # UNCHANGED
│       ├── gantt.typ                      # MODIFIED — use new gantt shape
│       ├── issue-log.typ                  # UNCHANGED
│       ├── lessons-learned.typ            # UNCHANGED
│       ├── milestones.typ                 # UNCHANGED
│       ├── objectives.typ                 # UNCHANGED
│       ├── pitch.typ                      # UNCHANGED
│       ├── risk-matrix.typ                # UNCHANGED
│       ├── sign-off.typ                   # UNCHANGED
│       ├── status-report.typ              # UNCHANGED
│       ├── team.typ                       # UNCHANGED
│       ├── acceptance.typ                 # NEW
│       ├── assumptions-log.typ            # NEW
│       ├── benefits-review.typ            # NEW
│       ├── communication.typ              # NEW
│       ├── compliance.typ                 # NEW
│       ├── decision-log.typ               # NEW
│       ├── deliverables-register.typ      # NEW
│       ├── financial-closure.typ          # NEW
│       ├── handover.typ                   # NEW
│       ├── quality.typ                    # NEW
│       ├── requirements.typ               # NEW
│       ├── risk-strategy.typ              # NEW
│       ├── stakeholders.typ               # NEW
│       └── success-criteria.typ           # NEW
├── src/
│   ├── lib.typ                            # MODIFIED — export new components
│   ├── components/
│   │   ├── initiation.typ                 # MODIFIED — add success-criteria, stakeholders, assumptions-log
│   │   ├── planning.typ                   # MODIFIED — add requirements, quality, communication, risk-strategy, compliance; enhance budget, gantt
│   │   ├── execution.typ                  # MODIFIED — add decision-log, deliverables-register; enhance change-log
│   │   └── closure.typ                    # MODIFIED — add acceptance, benefits-review, handover, financial-closure
│   ├── core/
│   │   ├── audit.typ                      # MODIFIED — schema grows to 30 paths
│   │   ├── fallback.typ                   # UNCHANGED
│   │   ├── guard.typ                      # UNCHANGED
│   │   ├── orchestrator.typ               # UNCHANGED (pipeline-driven, already generic)
│   │   ├── pipeline.typ                   # MODIFIED — 28 entries
│   │   ├── refs.typ                       # MODIFIED — 6 new label families
│   │   ├── resolve.typ                    # UNCHANGED
│   │   ├── schema.typ                     # MODIFIED — 30 entries
│   │   └── state.typ                      # UNCHANGED
│   ├── phases/
│   │   ├── initiation.typ                 # UNCHANGED (already generic, reads pipeline)
│   │   ├── planning.typ                   # UNCHANGED
│   │   ├── execution.typ                  # UNCHANGED
│   │   ├── closure.typ                    # UNCHANGED
│   │   └── custom.typ                     # UNCHANGED
│   ├── primitives/
│   │   ├── badge.typ                      # UNCHANGED
│   │   ├── card.typ                       # UNCHANGED
│   │   ├── data-table.typ                 # UNCHANGED
│   │   ├── metric.typ                     # UNCHANGED
│   │   └── progress-bar.typ               # UNCHANGED
│   ├── theme/
│   │   ├── resolver.typ                   # UNCHANGED
│   │   ├── tokens.typ                     # UNCHANGED
│   │   └── ui.typ                         # UNCHANGED
│   └── utils/
│       └── formatters.typ                 # UNCHANGED
```

### Component Responsibilities

| Component File | Responsibility | Exposes | Consumes | Must NOT |
|---|---|---|---|---|
| `components/initiation.typ` | Render initiation-phase sections | `cover`, `pitch`, `business-case`, `objectives`, `success-criteria`, `stakeholders`, `assumptions-log` | `core/resolve`, `core/state`, `core/refs`, `theme/ui` | Import from other component files |
| `components/planning.typ` | Render planning-phase sections | `boundaries`, `requirements`, `milestones`, `budget`, `gantt`, `quality`, `communication`, `risk-strategy`, `compliance`, `team` | `core/resolve`, `core/state`, `core/refs`, `theme/ui`, `utils/formatters`, `gantty` (for gantt only) | Import from other component files |
| `components/execution.typ` | Render execution-phase sections | `status-report`, `risk-matrix`, `issue-log`, `change-log`, `decision-log`, `deliverables-register` | `core/resolve`, `core/state`, `core/refs`, `theme/ui` | Import from other component files |
| `components/closure.typ` | Render closure-phase sections | `lessons-learned`, `sign-off`, `acceptance`, `benefits-review`, `handover`, `financial-closure` | `core/resolve`, `core/state`, `core/refs`, `theme/ui`, `utils/formatters` | Import from other component files |
| `core/pipeline.typ` | Define the default section ordering | `pmbok-pipeline` (array of 28 records) | All component render functions | Contain rendering logic |
| `core/refs.typ` | Create and resolve cross-reference labels | 11 label families + `safe-link` + `folio-orphans` | Nothing (leaf module) | Access state or resolve data |
| `core/schema.typ` | Define the audit checklist | `folio-schema` (array of 30 path records) | Nothing (leaf module) | Contain rendering logic |

---

## 5. Trade-off Analysis

```
DECISION: External dependency for visual Gantt
OPTIONS CONSIDERED:
  A. Zero dependencies — table-only Gantt, users import gantty themselves
     + No dep management. Simpler packaging.
     − Consumer has to wire gantty into extra-sections manually. Poor out-of-box experience.
  B. Hard dependency on gantty — folio declares it in typst.toml
     + Visual Gantt out of the box. One-line consumer experience.
     − First external dependency. Tied to gantty's release cycle.
  C. Soft/optional — try import, fall back to table
     + Best of both worlds in theory.
     − Typst doesn't have clean conditional imports. Fragile, confusing errors.
CHOSEN: B
REASON: folio is opinionated about everything else (theme, pipeline, audit). One curated
dependency for a visual Gantt is consistent with the philosophy. gantty is actively maintained
and Typst-native.
REVISIT IF: gantty becomes unmaintained, or Typst adds a built-in charting API.
```

```
DECISION: Budget component — backward compatibility strategy
OPTIONS CONSIDERED:
  A. Breaking change — new shape only, old examples updated
     + Clean code. No branching logic in the component.
     − Breaks any external consumer using the old (description, amount) shape.
  B. Shape detection — if input is flat array of (description, amount), render simple table;
     if input is dict with line_items/extra_costs, render rich table
     + Backward compatible. Existing examples keep working unchanged.
     − Branching logic in the component. Two code paths to maintain.
CHOSEN: B
REASON: v0.0.1 hasn't shipped yet, so there are no external consumers to break — but the
existing examples ARE the test suite. Keeping them working without modification is the
project's own constraint. Shape detection is a one-time check at the top of the function.
REVISIT IF: After v0.1.0 ships and the old shape is deprecated.
```

```
DECISION: Cross-reference depth
OPTIONS CONSIDERED:
  A. ID-based linking only — entities have IDs, refs render as clickable links, orphans detected
     + Simple. Proven pattern in existing refs.typ. No data traversal pass needed.
     − No computed aggregates (e.g., "total budget for REQ-01").
  B. ID-based linking + automatic rollups — folio computes aggregates across sections
     + Powerful. Budget shows per-requirement totals. Risk count per milestone.
     − Complex. Requires a pre-render data traversal pass. Edge cases (circular refs, missing IDs).
       Significantly increases implementation scope.
CHOSEN: A (v0.0.1), B deferred to v0.1.0
REASON: Links are the high-value, low-complexity win. Rollups are powerful but triple the
implementation effort for cross-referencing. Ship links first, learn from real usage, then
add rollups where they actually matter.
REVISIT IF: Multiple consumers request rollups, or the audit dashboard needs aggregate metrics.
```

```
DECISION: Gantt data shape — nested phases with subtasks vs. flat task list
OPTIONS CONSIDERED:
  A. Flat task list — (id, name, start, end, progress)
     + Simple schema. Easy to write.
     − No visual grouping. Loses the phase structure that makes Gantt charts readable.
  B. Nested phases with subtasks — matches gantty's input format and 01's data shape
     + Visual grouping by phase. Matches how project managers think. Direct gantty passthrough.
     − Deeper nesting in the data dict. Schema is more complex.
CHOSEN: B
REASON: A Gantt chart without phase grouping is just a list with dates. The visual grouping
IS the value. The nesting matches gantty's expected input, so the component is a thin
theming wrapper, not a data transformer.
REVISIT IF: gantty changes its input format.
```

```
DECISION: Where to put new component functions — one file per phase vs. one file per section
OPTIONS CONSIDERED:
  A. One file per phase (current) — initiation.typ, planning.typ, execution.typ, closure.typ
     + Fewer files. Clear phase grouping. Existing pattern.
     − Files grow large (planning.typ will have 10 functions).
  B. One file per section — pitch.typ, budget.typ, gantt.typ, requirements.typ, ...
     + Small focused files. Easy to find a specific component.
     − 28 files in components/. Import overhead. Breaks existing pattern.
CHOSEN: A
REASON: Consistency with the existing codebase. The phase files are already the pattern.
Planning.typ with 10 functions is still manageable — each function is 20-40 lines.
Splitting later is a non-breaking refactor if files get unwieldy.
REVISIT IF: Any single component file exceeds 500 lines.
```

---

## 6. Phased Implementation Plan

### Phase 1 — Foundation: refs + schema + pipeline expansion

**Goal:** Extend the engine to know about all 30 paths and 11 label families. No new rendering yet — but the audit dashboard reports all new paths as "Missing," and the pipeline has slots for all 28 sections.

**Components to modify:**
- `core/refs.typ` — Add 6 new label families: `req-label`, `deliverable-label`, `assumption-label`, `decision-label`, `stakeholder-label`, `objective-label`. Add corresponding `link-to-*` functions.
- `core/schema.typ` — Expand from 16 to 30 entries.
- `core/pipeline.typ` — Expand from 14 to 28 entries. New entries point to stub render functions that output `missing("section_id — not yet implemented")`.
- `src/lib.typ` — Export new label/link functions from refs.
- `typst.toml` — Add `gantty` dependency.

**Dependencies:** None. This is the foundation.

**Exit criteria:**
```bash
# All existing examples compile without modification
fd -e typ -E data.typ . examples/ -x typst compile {}

# The audit dashboard on project-01-audit shows all 30 paths
# (14 as Present/Empty, 16 new ones as Missing)
typst compile examples/project-01-audit.typ

# The pipeline has 28 entries (verify by inspection)
```

**Risk flags:**
- [LOW] Adding stub render functions to pipeline means new sections show `missing()` placeholders until their components are built. This is by design — graceful degradation.

---

### Phase 2 — Initiation expansion: success_criteria + stakeholders + assumptions_log

**Goal:** Three new initiation-phase components, fully rendered and cross-referenced.

**Components to modify:**
- `components/initiation.typ` — Add `success-criteria`, `stakeholders`, `assumptions-log` functions.
- `core/pipeline.typ` — Replace stubs with real render functions for these 3 sections.

**Components to create:**
- `examples/components/success-criteria.typ` — Standalone fixture.
- `examples/components/stakeholders.typ` — Standalone fixture.
- `examples/components/assumptions-log.typ` — Standalone fixture.

**Fixtures to modify:**
- `examples/data.typ` — Add `initiation.success_criteria`, `initiation.stakeholders`, `initiation.assumptions_log` to the shared data dict.

**Cross-refs to implement:**
- `success-criteria` → `link-to-objective` (objective_id field)
- `stakeholders` → `stakeholder-label` emission
- `assumptions-log` → `link-to-risk` (risk_id field), `assumption-label` emission

**Exit criteria:**
```bash
# All existing examples still compile
fd -e typ -E data.typ . examples/ -x typst compile {}

# New standalone component fixtures compile
typst compile examples/components/success-criteria.typ
typst compile examples/components/stakeholders.typ
typst compile examples/components/assumptions-log.typ

# project-01-audit shows the 3 new sections as Present (data.typ has data)
typst compile examples/project-01-audit.typ
# Visual inspection: new sections render tables with correct cross-ref links
```

**Risk flags:** None. Additive only.

---

### Phase 3 — Planning expansion: requirements + quality + communication + risk_strategy + compliance

**Goal:** Five new planning-phase components. The big one is `requirements` — the richest new component, with category grouping, subtotals, and cross-ref label emission.

**Components to modify:**
- `components/planning.typ` — Add `requirements`, `quality`, `communication`, `risk-strategy`, `compliance` functions.
- `core/pipeline.typ` — Replace stubs with real render functions.

**Components to create:**
- `examples/components/requirements.typ`
- `examples/components/quality.typ`
- `examples/components/communication.typ`
- `examples/components/risk-strategy.typ`
- `examples/components/compliance.typ`

**Fixtures to modify:**
- `examples/data.typ` — Add `baselines.requirements`, `baselines.quality`, `baselines.communication`, `baselines.risk_strategy`, `baselines.compliance`.

**Cross-refs to implement:**
- `requirements` → `req-label` emission. Budget line items will reference these in Phase 4.
- `quality` → `link-to-req` (req_id in criteria)
- `compliance` → `link-to-req` (req_ids), `compliance-label` emission

**Exit criteria:**
```bash
# All examples compile
fd -e typ -E data.typ . examples/ -x typst compile {}

# New fixtures compile
typst compile examples/components/requirements.typ
typst compile examples/components/quality.typ
typst compile examples/components/communication.typ
typst compile examples/components/risk-strategy.typ
typst compile examples/components/compliance.typ

# Requirements table renders with:
#   - Category grouping
#   - Subtotals per category
#   - Grand total
#   - Priority badges
#   - req-label on each row
# Visual inspection of examples/project-01-audit.typ
```

**Risk flags:**
- [MEDIUM] `requirements` component has the most complex rendering logic (category grouping, subtotals). Thorough visual inspection needed.

---

### Phase 4 — Budget + Gantt enhancement

**Goal:** Upgrade the two existing components with richer data shapes while maintaining backward compatibility.

**Components to modify:**
- `components/planning.typ` — Rewrite `budget` (shape detection + rich rendering) and `gantt` (gantty integration + theming).

**Fixtures to modify:**
- `examples/components/budget.typ` — Update to use the new rich shape.
- `examples/components/gantt.typ` — Update to use the new nested shape.
- `examples/data.typ` — Update `baselines.financials.budget` to new shape, update `baselines.schedule.gantt` to nested shape.

**Backward compatibility verification:**
- The old `budget` shape `((description: "X", amount: 5000),)` must still render the simple table.
- Test with both old and new shapes.

**Cross-refs to implement:**
- `budget` line items → `link-to-req` (req_id field)
- `gantt` tasks → `task-label` emission (already exists, but verify with new nested shape)

**Exit criteria:**
```bash
# All existing examples compile (backward compat)
fd -e typ -E data.typ . examples/ -x typst compile {}

# Budget with old shape still works
# Create a one-off test:
echo '#import "@local/folio:0.0.1": budget, folio-init
#show: body => folio-init(data: (baselines: (financials: (budget: ((description: "Old Shape", amount: 5000),)))), body)
#budget("baselines.financials.budget")' > /tmp/test-old-budget.typ
typst compile /tmp/test-old-budget.typ

# Budget with new shape renders rich table
typst compile examples/components/budget.typ
# Visual inspection: category grouping, subtotals, extra costs, grand total

# Gantt renders visual chart via gantty
typst compile examples/components/gantt.typ
# Visual inspection: phase bars, day headers, milestone markers, themed colors
```

**Risk flags:**
- [HIGH] `gantty` integration. The theming (colors from folio tokens passed to gantty drawer config) is the tricky part. gantty's drawer API accepts style dicts — folio needs to map its tokens to gantty's expected format.
- [MEDIUM] Budget shape detection. Must reliably distinguish old flat array from new dict shape.

---

### Phase 5 — Execution expansion: decision_log + deliverables_register + enhanced cross-refs

**Goal:** Two new execution-phase components. Enhance `change-log` with `type` and `affects_baseline` fields. Enhance `issue-log` with `blocks_deliverable`. Enhance `risk-register` with `source_assumption`.

**Components to modify:**
- `components/execution.typ` — Add `decision-log`, `deliverables-register`. Enhance `change-log`, `issue-log`, `risk-matrix` with new cross-ref fields.
- `core/pipeline.typ` — Replace stubs.

**Components to create:**
- `examples/components/decision-log.typ`
- `examples/components/deliverables-register.typ`

**Fixtures to modify:**
- `examples/data.typ` — Add `registers.decision_log`, `registers.deliverables_register`. Add new fields to existing risk/issue/change entries.

**Cross-refs to implement:**
- `decision-log` → `link-to-risk` (prompted_by_risk), `link-to-issue` (prompted_by_issue), `decision-label` emission
- `deliverables-register` → `link-to-req` (req_ids), `deliverable-label` emission
- `issue-log` → `link-to-deliverable` (blocks_deliverable) — NEW
- `change-log` — display `type` and `affects_baseline` as metadata (no label link, just text)
- `risk-matrix` → `link-to-assumption` (source_assumption) — NEW

**Exit criteria:**
```bash
# All examples compile
fd -e typ -E data.typ . examples/ -x typst compile {}

# New fixtures compile
typst compile examples/components/decision-log.typ
typst compile examples/components/deliverables-register.typ

# Cross-refs work end-to-end:
#   - Decision log links to risks and issues
#   - Deliverables register links to requirements
#   - Issue log links to deliverables
#   - Risk matrix links to assumptions
# Verify via project-01-audit.typ: orphan section should show NO false orphans
typst compile examples/project-01-audit.typ
```

**Risk flags:**
- [MEDIUM] Cross-ref density is highest in this phase. Many entity types referencing each other. Orphan detection must handle all new label families correctly.

---

### Phase 6 — Closure expansion: acceptance + benefits_review + handover + financial_closure

**Goal:** Four new closure-phase components, completing the full PM standards coverage.

**Components to modify:**
- `components/closure.typ` — Add `acceptance`, `benefits-review`, `handover`, `financial-closure`.
- `core/pipeline.typ` — Replace stubs.

**Components to create:**
- `examples/components/acceptance.typ`
- `examples/components/benefits-review.typ`
- `examples/components/handover.typ`
- `examples/components/financial-closure.typ`

**Fixtures to modify:**
- `examples/data.typ` — Add `closure.acceptance`, `closure.benefits_review`, `closure.handover`, `closure.financial_closure`.

**Cross-refs to implement:**
- `acceptance` → `link-to-deliverable` (deliverable_id)
- `benefits-review` → `link-to-objective` (objective_id)
- `financial-closure` → references budget baseline (display comparison, no label link)

**Exit criteria:**
```bash
# All examples compile
fd -e typ -E data.typ . examples/ -x typst compile {}

# New fixtures compile
typst compile examples/components/acceptance.typ
typst compile examples/components/benefits-review.typ
typst compile examples/components/handover.typ
typst compile examples/components/financial-closure.typ

# Full pipeline renders all 28 sections when data is present
typst compile examples/project-01-audit.typ
# Visual inspection: all sections render, audit dashboard shows all 30 paths as Present
```

**Risk flags:** None. Pattern is well-established by this phase.

---

### Phase 7 — Full integration: full-standards fixture + lib.typ exports + final audit

**Goal:** Create the comprehensive test fixture (`full-standards.typ`) that exercises every section, every cross-reference, and every edge case. Finalize `lib.typ` exports. Update examples, README, justfile.

**Components to create:**
- `examples/full-standards.typ` — Consumer file using all 28 sections with rich cross-referencing. This is the "can folio handle a real PM document with full standards coverage?" test.
- `examples/data-full.typ` — Complete data dict exercising all 30 schema paths with valid cross-references (every req_id, risk_id, deliverable_id, objective_id, etc. points to a real entity).

**Components to modify:**
- `src/lib.typ` — Export all new component functions, label functions, link functions.
- `justfile` — Add `just test-full` target.
- `README.md` — Update feature list, quickstart, section inventory.

**Exit criteria:**
```bash
# THE FULL TEST — every example compiles
just test

# Full standards fixture compiles and renders all 28 sections
typst compile examples/full-standards.typ
# Visual inspection:
#   - All 28 sections render with correct data
#   - All cross-reference links are clickable (not orphaned)
#   - Audit dashboard shows all 30 paths as Present
#   - No red "missing" placeholders anywhere in the main document
#   - Orphan references section shows "No orphan references detected"

# Minimal fixture still works (zero-crash guarantee with empty data)
typst compile examples/minimal.typ
# Visual inspection: compiles cleanly, shows missing placeholders, no crash

# Backward compatibility: old examples unchanged
typst compile examples/project-01.typ
typst compile examples/rfp.typ
typst compile examples/thesis.typ

# All standalone component fixtures compile
fd -e typ . examples/components/ -x typst compile {}
```

**Risk flags:**
- [MEDIUM] `lib.typ` export surface grows significantly. Must verify no name collisions between new component functions and existing exports.

---

## 7. Implementation Management

### Sequencing (dependency graph)

```
Phase 1 (foundation)
    │
    ├──► Phase 2 (initiation expansion)
    │        │
    │        └──► Phase 5 (execution expansion)
    │                  │ (needs assumption labels from P2,
    │                  │  deliverable labels from P3)
    │
    ├──► Phase 3 (planning expansion)
    │        │
    │        ├──► Phase 4 (budget + gantt enhancement)
    │        │        │ (budget needs req labels from P3)
    │        │        │
    │        └──► Phase 5 (execution expansion)
    │                  │ (deliverables-register needs req labels from P3)
    │
    └──► Phase 6 (closure expansion)
              │ (needs deliverable labels from P5,
              │  objective labels from P2)
              │
              └──► Phase 7 (full integration)
```

**Critical path:** Phase 1 → Phase 3 → Phase 4 → Phase 5 → Phase 6 → Phase 7.

Phase 2 can run in parallel with Phase 3 (no dependency between initiation and planning components). Phase 6 depends on Phase 5 (deliverable labels) and Phase 2 (objective labels).

### Ownership
Solo developer. No ownership split needed. Recommended order follows the critical path.

### Breaking Changes
- [HIGH RISK] Budget data shape change. Mitigated by shape detection (backward compat). But any consumer who reads folio's budget data directly (not through the component) will see a different structure. Documented in SCHEMA-MAP.md.
- [HIGH RISK] Gantt data shape change. Same mitigation — shape detection. Old flat array renders table; new dict renders visual chart.
- `typst.toml` adding `gantty` dependency. Not breaking for consumers — Typst resolves it automatically.
- Pipeline expansion from 14 → 28 entries. Not breaking — new entries use `auto` toggle, so they only render when data is present.

### Integration Points
- **Budget ↔ Requirements:** Budget `req_id` references must match requirement `id` values. No validation at compile time (runtime orphan detection via refs). [MEDIUM RISK]
- **gantty ↔ folio theming:** gantty's drawer styles must be mapped from folio tokens. This is a one-time integration in the `gantt` component. [HIGH RISK — needs spike]

---

## 8. Validation & Testing Strategy

### Testing Model

folio's correctness is empirical, not unit-tested. From the manifest:

> 1. **Compile** — every fixture must compile cleanly. A failed compile is a regression.
> 2. **Inspect** — a human (or a model with vision) reviews the rendered PDF.
> 3. **Snapshot** — once accepted, a snapshot is captured.

### Test Matrix

| Layer | Test Type | What it verifies | How |
|---|---|---|---|
| Schema | Compile test | All 30 paths recognized by audit | `typst compile examples/project-01-audit.typ` — audit dashboard lists all paths |
| Pipeline | Compile test | All 28 sections render when data present | `typst compile examples/full-standards.typ` — no missing placeholders |
| Components | Compile test | Each component renders independently | `fd -e typ . examples/components/ -x typst compile {}` — all 28 fixtures compile |
| Cross-refs | Compile test + inspection | Links resolve, orphans detected | `typst compile examples/full-standards.typ` — orphan section empty; all links clickable |
| Backward compat | Compile test | Old examples unchanged | `typst compile examples/{minimal,project-01,rfp,thesis}.typ` |
| Zero-crash | Compile test | Empty data compiles | `typst compile examples/minimal.typ` |
| Budget compat | Compile test | Old shape still works | One-off fixture with `(description, amount)` flat array |
| Gantt compat | Compile test | Old shape still works | One-off fixture with flat task list [ASSUMPTION: old gantt shape needs compat too] |
| Theming | Inspection | Brand overrides propagate to all new components | Fixture with custom `brand: (palette: (primary: rgb("#ff0000")))` — visual check |

### CLI Test Commands (justfile targets)

```just
# Compile all examples (existing target, enhanced)
[group('CI')]
compile:
    fd -e typ -E data.typ -E data-full.typ . examples/ -x typst compile {}

# Full regression suite
[group('CI')]
test: clean compile list
    @echo "✓ All fixtures compiled"
    fd -uu -e pdf -t f -X rm -f

# Compile the full-standards fixture specifically (slow, all 28 sections)
[group('CI')]
test-full:
    typst compile examples/full-standards.typ
    @echo "✓ Full standards fixture compiled"

# Compile all standalone component fixtures
[group('CI')]
test-components:
    fd -e typ . examples/components/ -x typst compile {}
    @echo "✓ All component fixtures compiled"
```

### Per-Phase Validation Checklist

Every phase in the implementation plan includes explicit `Exit criteria` with exact CLI commands. The pattern is always:

1. `fd -e typ -E data.typ . examples/ -x typst compile {}` — backward compat
2. `typst compile examples/components/NEW-COMPONENT.typ` — new fixture compiles
3. `typst compile examples/project-01-audit.typ` — audit dashboard correct
4. Visual inspection of rendered PDF — correct layout, theming, cross-refs

A phase is not done until all four pass.

### Architecture Fitness Functions

- **No cross-component imports:** Components must only import from `core/` and `theme/`. Verified by grepping: `rg 'import.*components/' src/components/` should return only self-references within each file.
- **No upward dependencies:** `rg 'import.*phases/' src/components/` should return nothing. `rg 'import.*orchestrator' src/components/` should return nothing.
- **Public API completeness:** Every component function in `components/*.typ` must be exported in `lib.typ`. Verified by comparing function counts.
- **Schema-pipeline alignment:** Every entry in `schema.typ` must have a corresponding pipeline entry (or be a meta path like `project.name`). Every pipeline entry must have a schema entry. Verified by inspection.

---

## 9. Open Questions & Risks

1. **gantty theming integration.** The exact mapping from folio tokens to gantty drawer styles needs a spike. gantty's drawer API accepts nested dicts with `stroke`, `fill`, `width` — folio needs to construct these from `resolve-token` calls. Recommend: build the gantt component first as a standalone experiment before integrating into the phase.

2. **Budget extra_costs percentage computation.** The schema says `percentage: 0.10` means "10% of line_items subtotal." This requires computing the subtotal first, then the percentage, then adding to grand total. The computation must happen inside the component, not in the consumer's data. Verify this doesn't conflict with Typst's evaluation model (it shouldn't — it's pure arithmetic on the data dict).

3. **Orphan detection at scale.** With 11 label families and 20+ cross-reference relationships, the orphan detection system in `refs.typ` could produce noisy output. Consider grouping orphans by entity type in the audit dashboard, and possibly adding a severity level (orphaned risk ref is more important than orphaned assumption ref).

4. **`full-standards.typ` data size.** A data dict with all 30 paths populated, including arrays of requirements, risks, issues, deliverables, etc., could be large. Consider splitting into `data-full.typ` as a separate file from the existing `data.typ` to avoid bloating the shared fixture.

5. **Component file size.** `components/planning.typ` will have 10 render functions after Phase 3. If any function exceeds ~50 lines (likely for `requirements` and `budget`), consider extracting helpers within the file rather than splitting into separate files. Revisit the one-file-per-phase decision if the file exceeds 500 lines.

6. [REVISIT] **Gantt backward compatibility.** The current gantt shape is a flat array `((id, name, start, end, progress), ...)`. The new shape is a nested dict `(start, end, tasks: ((name, subtasks: (...)), ...), milestones: (...))`. Shape detection can distinguish these (array vs. dict), but the old table rendering must be preserved for consumers using the flat shape. Confirm this is desired or if breaking the old gantt shape is acceptable since v0.0.1 hasn't shipped.