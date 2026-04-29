# folio v0.0.1 — Completion Plan

> **Continuation of `PLAN.md`.** The original plan defined the architecture; this plan closes the gaps between the current implementation (`folio-20260429`) and the original Definition of Done. Architecture decisions are inherited unchanged from `MANIFEST.md` and `PLAN.md` — this document is execution-focused, not re-design.
>
> **Audience**: a model agent or engineer completing v0.0.1. **Style**: file-specific, ordered by dependency, every phase shippable in isolation.

---

## 0. Executive Summary

The current folio implementation is structurally correct but functionally short of the v0.0.1 contract. The naming pass, schema-as-data refactor, primitive/adapter split, refs system, and section render functions are all in place and working. What's missing are the four UX-defining capabilities that distinguish folio from a renamed scaffold: phase callables for partial rendering, a TOC and level-1 phase structure that makes documents skimmable, an audit system that actually surfaces orphan references (the original concern that started this whole thing), and pluggable formatters/brand overlays that make folio adoptable by any project. This plan closes those gaps in four sequenced phases — call them Phase 6 through Phase 9 if anchored to the original plan — each independently verifiable. Total surface area touched: ~7 files. The architecture does not change.

---

## 1. Audit of Current State

### Landed correctly (do not touch)
- File renames: kebab-case in `src/`, English everywhere in `src/`.
- Public API surface in `src/lib.typ` matches the closed list from PLAN.md §3.
- `src/core/schema.typ` exists; audit reads from it; `pmbok-registry` constant is gone.
- Section render functions (`cover`, `pitch`, `business-case`, `objectives`, `boundaries`, `milestones`, `budget`, `gantt`, `team`, `status-report`, `risk-matrix`, `issue-log`, `change-log`, `lessons-learned`, `sign-off`) all exist and consume schema paths through `resolve`.
- Refs system: label factories + `safe-link` + `link-to-*` helpers all exist. Cross-references in `risk-matrix` and `issue-log` use them correctly.
- `section-guard`, `resolve`, `nonempty`, `get-title`, `missing` all named per plan.
- Primitive/UI-adapter split: primitives in `src/primitives/`, token-aware wrappers in `src/theme/ui.typ`.

### Gaps blocking v0.0.1
| # | Gap | File(s) | Severity |
|---|---|---|---|
| 1 | No `initiation()`/`planning()`/`execution()`/`closure()` phase callables | `src/phases/*.typ`, `src/lib.typ` | Critical |
| 2 | No level-1 phase headings | `src/phases/*.typ` | Critical |
| 3 | No TOC in `project-doc` | `src/core/orchestrator.typ` | Critical |
| 4 | Orphan registry not implemented; audit not split | `src/core/refs.typ`, `src/core/audit.typ` | Critical |
| 5 | No `config.extra-sections` injection | `src/core/orchestrator.typ` | Important |
| 6 | No `config.extra-checks` merging | `src/core/audit.typ` | Important |
| 7 | `format-money`/`format-date` ignore state config overrides | `src/utils/formatters.typ` | Important |
| 8 | Brand typography/geometry not applied at page level | `src/core/state.typ` | Important |
| 9 | Schema↔pipeline parity not asserted | new fixture | Important |
| 10 | Examples don't prove "any project" claim | `examples/` | Critical |
| 11 | `cover()` emits `pagebreak()` itself | `src/phases/initiation.typ` | Minor |
| 12 | `examples/components/*.typ` still snake_case | `examples/components/` | Minor |
| 13 | `missing()` has redundant nested brackets | `src/core/fallback.typ` | Cosmetic |

---

## 2. Design Decisions (continuations, not reopens)

These resolve implementation ambiguities surfaced by the audit. They are minor calibrations, not architecture changes.

### Phase callable shape
**Decision**: each phase callable is a content function — not a show-rule closure — that emits a level-1 heading with the phase's display name, then iterates the orchestrator's pipeline filtered by that phase, dispatching each entry through `section-guard`. Phase callables read state via `folio-state.get()` inside a `context {}` block; they assume `folio-init` has already populated state. This is the lightweight pattern from PLAN.md DECISION 6.

**Naming**: phase callable display names — "Initiation", "Planning", "Execution", "Closure" — are hardcoded English in the phase functions. Title customization per project happens through the existing `get-title` mechanism using a new schema path (`phases.<phase>.title`).

### Cover responsibility
**Decision**: `cover()` emits the cover content only (no pagebreak). The orchestrator's `project-doc` issues the `pagebreak()` after calling `cover()`. Standalone callers wanting a pagebreak add their own. This restores the principle that section functions are pure renderers.

### TOC placement and styling
**Decision**: native `outline(title: "Table of Contents", indent: auto, depth: 3)` after cover, before phase iteration. No brand-customizable TOC styling in v0.0.1 — Typst's native rendering is used as-is. Future versions may expose an outline-style brand token.

### Orphan registry mechanism
**Decision**: a second `state("folio-orphans", ())` accumulates records of shape `(label-target, source-section, source-id)` whenever `safe-link` fires its fallback path. The audit appendix at end-of-doc reads this state and renders the orphan table. The known limitation — single-pass compiles produce incomplete orphan lists — is documented in `README.md`, `MANIFEST.md`, and inline near the audit appendix output.

### Audit split
**Decision**: `data-audit()` retains its current name as a deprecated alias and now internally calls `data-audit-header()`. Two new public exports: `data-audit-header()` (severity dashboard, runs before cover when `config.audit == true`) and `data-audit-orphans()` (orphan appendix, runs at end-of-doc). `project-doc` calls both at the right positions when `config.audit == true`.

### Extra sections injection
**Decision**: `config.extra-sections` is a list of records `(id, phase, after | before, data-path, render)`. The orchestrator merges these into the pipeline before iteration, resolving anchors by section_id. Anchor collisions or unknown anchors `panic` with a clear message naming the offending IDs. If both `after` and `before` are supplied, `after` wins; if neither, the section appends to the end of its phase.

### Extra checks
**Decision**: `config.extra-checks` is a list of records matching the schema record shape `(path, severity, phase, kind)`. The audit concatenates them with `folio-schema` before computing the dashboard. Severity must be one of `{critical, important, recommended}` — anything else `panic`s.

### Formatter overrides
**Decision**: `format-money` and `format-date` first read `state.config.format-money` (or `format-date`); if the value is a function, call it with the input and return its result. If absent, fall through to the existing built-in defaults. Override functions receive raw values (numeric for money, ISO-string for dates) and return content. No structured locale dict — pure function override only.

### Brand application at page level
**Decision**: `folio-init` applies brand-driven `set` rules at the page level after populating state. Specifically: `set text(font: <typography.family>, size: <typography.size.body>)` and `set page(margin: <geometry.margin>)`, both reading from the resolved brand-or-default token tree. This makes brand typography and geometry actually take effect, not just brand colors (which already work because primitives query tokens).

### Schema-pipeline parity
**Decision**: a fixture `tests/fixtures/parity.typ` imports both `folio-schema` and the `pmbok-pipeline` constant (newly exported, even if internal-prefixed) and asserts every `data_path` in the pipeline has a corresponding `path` in the schema. Failure renders a visible error block in the test output. This is the architecture fitness function from PLAN.md §8.

---

## 3. Phased Implementation

Four phases, ordered by dependency. Each is independently shippable and reviewable.

### Phase 6 — Phase callables, level-1 headings, TOC, cover relocation

**Goal**: complete the document chrome and partial-rendering UX.

**Components**:
- In `src/phases/initiation.typ`: add `let initiation()` that emits `heading(level: 1)[Initiation]` then iterates the pipeline filtered by `phase == "initiation"`, calling `section-guard` per record. To do this, the phase file needs access to the pipeline — either by importing it from `core/orchestrator.typ` (creating a circular import) or by having the orchestrator pass the pipeline subset to the phase fn. **Resolve via**: extracting the pipeline constant to a new file `src/core/pipeline.typ`, imported by both phase files and `orchestrator.typ`. This is the clean fix.
- Same for `planning.typ`, `execution.typ`, `closure.typ`.
- Export the four phase callables from `src/lib.typ`.
- In `src/phases/initiation.typ`: remove the `pagebreak()` from inside `cover()`.
- In `src/core/orchestrator.typ`: refactor `project-doc` so its body becomes — audit-header (if enabled) → cover → pagebreak → TOC → initiation() → planning() → execution() → closure() → audit-orphans (if enabled) → body. Replace the current pipeline-iteration loop with calls to the phase callables.
- Add the `outline(title: "Table of Contents", indent: auto, depth: 3)` between cover and `initiation()`.

**Dependencies**: none beyond current state.

**Exit criteria**:
- `#import "@local/folio:0.0.1": initiation, folio-init` and a body of `#show: rest => folio-init(data: data, config: (:), brand: (:), rest)` followed by `#initiation()` produces a document with a level-1 "Initiation" heading and only the initiation sections beneath it.
- `project-doc` output has, in order: cover page → TOC page → "1. Initiation" level-1 → initiation sections → "2. Planning" level-1 → planning sections → "3. Execution" level-1 → execution sections → "4. Closure" level-1 → closure sections.
- `cover()` standalone produces only cover content, no trailing pagebreak.
- The pipeline constant lives in exactly one file (`src/core/pipeline.typ`).

**Risk flags**: extracting the pipeline constant is mechanical but touches every phase file's imports. Verify no circular imports remain by trial compile of `examples/project-01.typ`.

---

### Phase 7 — Audit split + orphan registry + extra-sections + extra-checks + parity

**Goal**: complete the diagnostic system and unlock pipeline extensibility. Closes the original CONCERNS.md item that started this entire conversation.

**Components**:
- In `src/core/refs.typ`:
  - Declare `let folio-orphans = state("folio-orphans", ())`.
  - Refactor `safe-link` so the fallback branch additionally calls `folio-orphans.update(prev => prev + ((target: lbl, fallback: fallback-text),))` before emitting the fallback content.
  - Export `folio-orphans`.
- In `src/core/audit.typ`:
  - Rename current `data-audit` body into `data-audit-header()`.
  - Modify `data-audit-header()` to read `state.config.extra-checks` (default empty list) and concatenate with `folio-schema` before grouping by severity.
  - Validate every extra-check record has a valid severity; `panic` on invalid.
  - Add new `let data-audit-orphans()` that reads `folio-orphans` state, renders a level-2 heading "Orphan References" and a `data-table` with columns (Target, Source, Fallback Text). If the orphans list is empty, render a small "No orphan references detected" note instead.
  - Add `let data-audit() = { data-audit-header() }` as a deprecated compat alias (so existing `examples/audit.typ` keeps working).
  - Export `data-audit-header` and `data-audit-orphans`.
- In `src/lib.typ`: re-export `data-audit-header`, `data-audit-orphans`, `data-audit` (deprecated).
- In `src/core/orchestrator.typ`:
  - Replace the `data-audit()` call site with `data-audit-header()`.
  - Add `data-audit-orphans()` call after the four phase callables, before `body`.
  - Implement extra-sections injection: read `state.config.extra-sections` (default empty list); for each record, validate the anchor section_id exists in the base pipeline (`panic` if not, `panic` if id collision); insert into the pipeline list at the resolved position; pass the merged pipeline to the phase callables (which means phase callables now take an optional pipeline override argument, defaulting to the canonical pipeline).
- Add `tests/fixtures/parity.typ` that imports schema + pipeline and asserts every pipeline `data_path` has a matching schema `path`. Failure produces visible error block.

**Dependencies**: Phase 6 complete (phase callables must exist before they can accept the merged pipeline).

**Exit criteria**:
- A fixture document with a deliberate orphan reference (e.g. risk's `affects_wbs: ("WBS-99",)` where no WBS-99 task exists) compiles, renders the fallback `WBS-99?` text, and the orphan appendix at end-of-doc lists `WBS-99` with source attribution.
- `config.extra-checks: ((path: "governance.advisor", severity: "critical", phase: "meta", kind: "string"),)` causes the audit header to flag `governance.advisor` as missing under "Critical Data".
- `config.extra-sections: ((id: "scope-annex", phase: "planning", after: "boundaries", data-path: "annexes.scope", render: my-fn),)` renders `my-fn`'s output between `boundaries()` and `milestones()`.
- ID collision between built-in and custom sections produces a `panic` with the offending ID in the message.
- Compiling `tests/fixtures/parity.typ` succeeds; deliberately breaking the parity (adding a pipeline entry without a schema record) makes it fail with the misaligned path.

**Risk flags**:
- [HIGH] Orphan registry depends on Typst's layout-pass model. Single-pass compiles will under-report. Mitigation: explicit documentation in three places (README, MANIFEST, inline near appendix output).
- [MEDIUM] Adding `state.update` inside `safe-link` requires confirming all current call sites are inside `context {}`. Audit them.

---

### Phase 8 — Brand application at page level + formatter overrides

**Goal**: make the two configurable-by-data escape hatches actually work.

**Components**:
- In `src/core/state.typ`:
  - Inside `folio-init`, after populating state, query the resolved typography/geometry tokens (via `resolve-token` against the populated state) and emit `set text(...)` and `set page(...)` rules using those values.
  - Specifically: `set text(font: typography.family, size: typography.size.body)`; `set page(margin: geometry.page-margin, paper: geometry.paper)`.
  - These `set` rules must come before `body` is emitted so they apply to all subsequent content.
- In `src/utils/formatters.typ`:
  - Modify `format-money` to first read `st.config.format-money` (default `none`); if it's a function, return its result; else use the built-in.
  - Same for `format-date` reading `st.config.format-date`.
  - Document the override signature in a comment block at the top of the file: `format-money(amount: int|float) -> content`, `format-date(date-str: str "YYYY-MM-DD") -> content`.

**Dependencies**: none — independent of Phase 6 and Phase 7.

**Exit criteria**:
- `brand: (typography: (family: "Inter"))` causes the document body to render in Inter (visually inspectable).
- `brand: (geometry: (page-margin: 3cm))` causes pages to render with 3cm margins (visually inspectable).
- `config: (format-money: amt => [#amt MXN])` causes all money rendering to emit `<value> MXN` instead of `$<value>`.
- Same verified for `format-date`.
- Defaults (no override supplied) still produce existing English/USD output.
- Existing `examples/project-01.typ` compiles unchanged after this phase.

**Risk flags**: setting page margins from inside `folio-init` after content has potentially started rendering may have ordering effects. Verify `set page` placement works by compile-test before committing the change.

---

### Phase 9 — Examples + cleanup + verification

**Goal**: prove the satisfaction criterion ("any project compiles cleanly") and lock the verification loop.

**Components**:
- **Reshape `examples/project-01.typ`**: replace the Chimera Vision Core mock with a richer real project — UAEMéx telecom or whatever the actual project 01 was. Populate every section with realistic data, including cross-references that resolve correctly (no orphans in the production version) and at least one objective with `priority: "high"`. Remove `config: (audit: true)` from the production version; create a separate `examples/project-01-audit.typ` that imports the same data dict and turns audit on. This proves the schema works for non-trivial real data.
- **Add `examples/minimal.typ`**: only `project: (name: "Test Project")`. Compiles cleanly with all sections gracefully empty. Proves the zero-crash guarantee on the sparsest valid input.
- **Add `examples/thesis.typ`**: an academic project (e.g. "Sentiment analysis of Reddit threads, 2026 thesis") populating initiation + planning + closure but skipping execution registers (because thesis projects aren't run with risk/issue logs in the same way). Demonstrates section toggling via `config.sections`.
- **Add `examples/rfp.typ`**: a commercial RFP response (e.g. "Software consultancy proposal, 2026") with a custom section injected via `extra-sections` (e.g. "Pricing Annex" after `budget`). Demonstrates `extra-sections`.
- **Rename `examples/components/*.typ`** from snake_case to kebab-case (`business_case.typ` → `business-case.typ`, `change_log.typ` → `change-log.typ`, `issue_log.typ` → `issue-log.typ`, `lessons_learned.typ` → `lessons-learned.typ`, `risk_matrix.typ` → `risk-matrix.typ`, `sign_off.typ` → `sign-off.typ`, `status_report.typ` → `status-report.typ`).
- **Fix `src/core/fallback.typ`**: change `text(...)[ [Missing: #field-name] ]` to `text(...)[Missing: #field-name]`. Cosmetic but worth doing while files are open.
- **Build `tests/` directory**:
  - `tests/fixtures/` with: `minimal.typ`, `project-01.typ`, `parity.typ` (from Phase 7), `orphan-deliberate.typ` (project-01 + a deliberate broken ref to verify orphan reporting), `extra-sections.typ` (verifies injection), `extra-checks.typ` (verifies extra severity flagging).
  - `tests/snapshots/` (initially empty; populated when fixtures are first manually approved).
  - `tests/README.md` documenting the workflow: `typst compile <fixture> → manual review → `cp <output>.pdf snapshots/` → future runs `diff` against stored snapshot.
- **Update `README.md`**: replace the quickstart with the final 5-line example matching the manifest's success vignette. Add a sentence noting "audit orphan reporting is accurate after a second compile pass" near the audit usage block.

**Dependencies**: Phases 6, 7, 8 all complete.

**Exit criteria**:
- All four production examples (`minimal`, `project-01`, `thesis`, `rfp`) compile cleanly with no `Missing:` markers in production output.
- `examples/project-01-audit.typ` produces both severity dashboard and orphan appendix (orphan list may be empty for the clean case — that's acceptable).
- `tests/fixtures/orphan-deliberate.typ` produces a non-empty orphan appendix listing exactly the deliberately-broken reference.
- `tests/fixtures/extra-sections.typ` shows the injected section in the correct position.
- `tests/fixtures/extra-checks.typ` shows the additional check flagged in the audit header.
- `tests/fixtures/parity.typ` compiles successfully.
- `examples/components/` files all kebab-case.
- README quickstart, copy-pasted, compiles a valid PDF.

**Risk flags**: reshaping `project-01.typ` with realistic data may surface schema gaps (a field the actual project needs that isn't in `folio-schema`). Treat each gap as a Phase 1 schema amendment, not a workaround. If you find more than 3 gaps, pause and consult before extending the schema — they may indicate a category of section that wasn't planned for.

---

## 4. Sequencing Diagram

```
Phase 6 — Phase callables + chrome
       │
       ▼
Phase 7 — Audit split + extras
       │
       ├──────────────┐
       ▼              ▼
Phase 8 — Brand    (parallel with 8 if desired)
       │
       └──────────────┐
                      ▼
              Phase 9 — Examples + verification
```

Phase 8 is parallelizable with Phase 7 if multiple agents/contributors are working. Critical path is 6 → 7 → 9.

---

## 5. Definition of Done — Updated

The release is shippable when **all** of the following hold:

1. ✅ `examples/minimal.typ`, `examples/project-01.typ`, `examples/thesis.typ`, `examples/rfp.typ` all compile cleanly with no `Missing:` markers in production output.
2. ✅ `examples/project-01-audit.typ` produces both header dashboard and orphan appendix.
3. ✅ Custom-section injection works: `examples/rfp.typ` (or a fixture) renders an injected section at the correct anchor.
4. ✅ Phase callables work standalone: a consumer using only `initiation()` after `folio-init` produces a valid partial document with a level-1 phase heading.
5. ✅ `format-money` and `format-date` overrides take effect when supplied; defaults render when not.
6. ✅ TOC renders after cover, depth 3, with phase-level (1) and section-level (2) entries.
7. ✅ Brand typography and geometry overrides apply at page level (not just colors).
8. ✅ Orphan registry collects orphans; appendix renders them at end-of-doc.
9. ✅ `config.extra-checks` and `config.extra-sections` both work.
10. ✅ Schema-pipeline parity fixture passes.
11. ✅ `examples/components/*.typ` files are kebab-case.
12. ✅ README quickstart, copy-pasted, compiles a valid PDF.

When this list is satisfied, folio v0.0.1 ships.

---

## 6. Out of Scope for This Plan

To be explicit — these are deferred to v0.1.0 or later:

- Schema additions beyond what the four examples require (stakeholder register, decision log, requirements traceability, etc — see `PM_STANDARDS_REFERENCE.md` for the long list of natural growth targets).
- Brand-customizable TOC styling.
- Locale/i18n support beyond the function-pointer escape hatch.
- An automated description-generated `docs/schema.md`.
- Snapshot-diff automation (manual approval is fine for v0.0.1).
- Compile-time linting (e.g. `no rgb() in section fns`) — currently checked by manual grep.
- Multi-volume or multi-file PDF output.
- Cross-reference graph visualization.

---

## 7. File Change Summary

For the executing agent's checklist:

| File | Phase | Change Type |
|---|---|---|
| `src/core/pipeline.typ` | 6 | New file (extracted constant) |
| `src/core/orchestrator.typ` | 6, 7 | Modified (composition, extra-sections, audit calls) |
| `src/phases/initiation.typ` | 6 | Modified (add `initiation()`, remove cover pagebreak) |
| `src/phases/planning.typ` | 6 | Modified (add `planning()`) |
| `src/phases/execution.typ` | 6 | Modified (add `execution()`) |
| `src/phases/closure.typ` | 6 | Modified (add `closure()`) |
| `src/lib.typ` | 6, 7 | Modified (export phase callables, audit splits) |
| `src/core/refs.typ` | 7 | Modified (orphan registry, safe-link mutation) |
| `src/core/audit.typ` | 7 | Modified (split into header + orphans, extra-checks) |
| `src/core/state.typ` | 8 | Modified (apply brand `set` rules) |
| `src/utils/formatters.typ` | 8 | Modified (read overrides from state) |
| `src/core/fallback.typ` | 9 | Modified (cosmetic bracket fix) |
| `examples/project-01.typ` | 9 | Modified (reshape with real data) |
| `examples/project-01-audit.typ` | 9 | New file |
| `examples/minimal.typ` | 9 | New file |
| `examples/thesis.typ` | 9 | New file |
| `examples/rfp.typ` | 9 | New file |
| `examples/components/*.typ` | 9 | Renamed (snake → kebab) |
| `tests/fixtures/*.typ` | 7, 9 | New files |
| `tests/README.md` | 9 | New file |
| `README.md` | 9 | Modified (quickstart) |

Total: ~7 source files modified, 1 new source file, ~10 example/test files added or renamed.

---

## 8. Risks (Updated)

- **[HIGH] Orphan registry layout-pass dependency** (carried from PLAN.md). Documentation is the only mitigation. Confirmed-acceptable in alignment.
- **[MEDIUM] Brand `set` rule ordering inside `folio-init`**. If `set page(margin: ...)` runs after content has already started flowing, Typst may not apply it retroactively. Verify with a brand-overridden compile-test in Phase 8 before considering the phase done.
- **[MEDIUM] Reshaping project-01 surfaces schema gaps**. Acceptable to amend `folio-schema` for genuine missing fields, but more than 3 amendments suggests the schema is under-specified for real projects — pause and reassess instead of patching.
- **[LOW] Pipeline constant extraction touches every phase file's imports**. Mechanical risk only; mitigated by trial compile.
- **[LOW] `data-audit()` deprecated alias**. Some users may have written code calling it directly. The alias keeps them working; the deprecation note in the source file is sufficient communication for v0.0.1.

---

## 9. Verification Loop

For each phase, the developer runs:
1. `typst compile examples/project-01.typ` — must compile without errors.
2. Visual inspection of the output PDF against the phase's exit criteria.
3. For Phase 7 onwards: `typst compile examples/project-01-audit.typ` — verify audit blocks render where expected.
4. For Phase 9: full fixture sweep — every file in `tests/fixtures/` compiles; every example in `examples/` compiles.

When all phases are done and the Definition of Done holds, tag `v0.0.1` and ship.