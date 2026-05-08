# folio v0.0.1 — Final Refactor & Completion TODO

> **Scope:** Close the gap between "compiles" and "ships". Every item here is a concrete, actionable task with a clear done-criterion. No backwards compat. `just test` passing clean is the floor; visual correctness of PDFs is the ceiling.

---

## 0. Executive Summary

folio's architecture is sound — the manifest principles are reflected in the implementation, the layering is coherent, and the fixes from the previous round landed correctly. What remains is a final tightening pass: fixing three compile-risk bugs in the import/export layer, eliminating residual dead code that survived the previous cleanup, resolving one duplicated pattern in the theme resolver, and making one explicit design decision about the requirements/budget SSOT that the codebase currently leaves ambiguous. After this pass, folio v0.0.1 ships with a public API that matches its manifest, a schema that matches its data, and a test harness that catches regressions at the compile level.

---

## 1. Context & Constraints

**Project:** folio — Typst package, single developer, v0.0.1 target.
**Test harness:** `just test` → `audit-style` + `clean` + `compile` + `list`. Clean run = done.
**Rules:**
- No backwards compatibility. Break anything; you're the only user.
- No code in this document — describe contracts and intent only.
- Public API must match what `lib.typ` exports; internal helpers must not be exported.
- All color literals must resolve through brand tokens; `audit-style` enforces this.
- No Spanish strings anywhere in source.
- `compute.typ` must have no dead aliases.
- Every file must be imported by at least one consumer; orphan files are deleted.

**Out of scope:**
- New sections or schema fields.
- Multi-currency, GAAP/IFRS, jurisdiction-aware tax.
- Snapshot-based visual regression (deferred to v0.1.0).
- Migration tooling.
- v0.1.0 features of any kind.

**[ASSUMPTION]** All fixes from the previous fix prompt are applied and `just test` currently passes. This TODO targets the residual issues identified in the feedback review.

**[ASSUMPTION]** The requirements/budget SSOT decision will be resolved in this round (see TODO-6). The explicit decision — whichever direction — is the blocker for calling v0.0.1 done.

---

## 2. Architecture Overview (current state)

```
src/lib.typ  ← PUBLIC SURFACE (currently over-exposes internals)
    │
    ├── core/orchestrator.typ     ← project-doc() entry point
    │       └── core/state.typ   ← folio-state, folio-init (INTERNAL)
    │       └── core/pipeline.typ← pmbok-pipeline registry
    │       └── phases/*.typ     ← phase runners (3-line wrappers)
    │               └── core/phase-runner.typ ← render-phase() (INTERNAL)
    │
    ├── components/*.typ          ← section render functions (28 sections)
    │       └── core/resolve.typ ← _walk, resolve, nonempty, get-title
    │       └── core/refs.typ    ← label families + safe-link + folio-orphans
    │       └── theme/ui.typ     ← themed primitive wrappers (INTERNAL adapter)
    │               └── primitives/*.typ ← raw primitives (explicit params)
    │               └── theme/resolver.typ ← resolve-token, resolve-spacing
    │                       └── theme/tokens.typ ← default-tokens (corporate)
    │                       └── theme/brand-packs/*.typ ← 3 presets
    │
    ├── compute.typ               ← pure cost + audit functions
    │       └── core/schema.typ  ← folio-schema registry
    │       └── core/resolve.typ ← _walk, nonempty
    │
    └── utils/
            ├── formatters.typ   ← format-money, format-date, format-percent
            └── validators.typ   ← context-aware wrappers around compute fns
```

**The two architectural problems remaining:**

1. `lib.typ` exposes the wrong layer — it imports section functions from `phases/` (which no longer re-exports them) and exposes internal machinery as public API.
2. `resolver.typ` has its own independent path-walking implementation that should use a local helper instead of three repeated loops.

---

## 3. Design Patterns & Standards (by concern)

### Pattern: Adapter Chain (theme layer)
`brand-packs/` → `tokens.typ` → `resolver.typ` → `ui.typ` → `primitives/`

**Why:** Separates the "what color is primary" question (brand packs) from the "how do I resolve a token path" question (resolver) from the "how do I call a raw primitive with themed values" question (ui.typ). Each layer has exactly one responsibility.

**Standard to enforce:** `ui.typ` is the only file allowed to import both `resolver.typ` and `primitives/`. Components import from `ui.typ` only. `primitives/` never imports from `theme/`. `resolver.typ` never imports from `core/` (no circular deps).

### Pattern: Pure Function Core (compute layer)
`compute.typ` exports only pure functions: given data dict → return value. No state access, no rendering, no side effects.

**Standard to enforce:** `compute.typ` must not import `state.typ`, `ui.typ`, or any primitive. Its only imports are `core/resolve.typ` (for `_walk`, `nonempty`) and `core/schema.typ` (for `folio-schema`). Any function in `compute.typ` that reads state is wrong.

### Pattern: Registry + Phase Runner (pipeline layer)
`pipeline.typ` is a pure data structure (array of records). `phase-runner.typ` is the single execution function. Phase files are 3-line delegation wrappers. No logic lives in phase files.

**Standard to enforce:** Phase files contain zero logic — only `render-phase(pipeline, "phase-id", "Default Title")`. Any section filtering, toggle checking, or heading rendering must live in `phase-runner.typ`.

### Pattern: Graceful Degradation (resolve layer)
Every data access goes through `resolve()` or `nonempty()`. Direct dict access (`data.at(...)`) is only allowed inside `compute.typ` pure functions where the fallback behavior is explicit (`at(..., default: ...)` chained).

**Standard to enforce:** Component files never call `data.at(path)` directly for schema fields. They call `resolve(data, path)` and get either the value or a `missing()` placeholder. This is what makes zero-crash possible.

### Pattern: Public Surface Contract (lib.typ)
`lib.typ` is the single import consumers ever write. It re-exports exactly the public API and nothing else. Internal machinery is never re-exported regardless of how useful it might seem.

**Boundary rule:** The following are INTERNAL and must not appear in `lib.typ` exports:
- `folio-state`, `folio-init` (state machinery)
- `_walk`, `section-guard`, `missing` (implementation helpers)
- `resolve-token`, `resolve-spacing` (theme internals)
- `nonempty`, `resolve` (data internals — useful but internal)
- `render-phase` (pipeline internal)
- `data-audit`, `data-audit-header`, `data-audit-orphans` (audit internals — exposed only via `config.audit: true`, not as user-callable functions)

---

## 4. Component Map & Task Inventory

### TODO-1 — Fix `lib.typ`: wrong import layer for section functions

**File:** `src/lib.typ`

**Problem:** Section functions (`business-case`, `cover`, `objectives`, `pitch`, etc.) are imported from `phases/initiation.typ`. After the phase-runner refactor, phase files only export the phase-level function (`initiation`, `planning`, etc.) — not the section-level functions. Section functions live in `components/`. This is a compile error.

**Fix:** Change the import source for all section functions from `phases/*.typ` to `components/*.typ`. The phase-level functions (`initiation`, `planning`, `execution`, `closure`, `custom`) are still imported from `phases/*.typ`.

**Correct import structure:**
- From `phases/initiation.typ` → import `initiation` only
- From `phases/planning.typ` → import `planning` only
- From `phases/execution.typ` → import `execution` only
- From `phases/closure.typ` → import `closure` only
- From `phases/custom.typ` → import `custom` only
- From `components/initiation.typ` → import all initiation section functions
- From `components/planning.typ` → import all planning section functions
- From `components/execution.typ` → import all execution section functions
- From `components/closure.typ` → import all closure section functions

**Done when:** `just compile` produces zero import errors on any consumer using section functions directly.

---

### TODO-2 — Fix `lib.typ`: trim internal exports from public surface

**File:** `src/lib.typ`

**Problem:** The following internal symbols are currently re-exported and must be removed from the public surface:
- `folio-state`, `folio-init` (from `core/state.typ`) — state machinery, consumers never call these
- `_walk` (from `core/resolve.typ`) — private helper, leading underscore signals internal
- `nonempty`, `resolve`, `missing` (from `core/resolve.typ` and `core/fallback.typ`) — internal data utilities
- `section-guard` (from `core/guard.typ`) — internal pipeline helper
- `resolve-token`, `resolve-spacing` (from `theme/resolver.typ`) — internal theme utilities
- `data-audit`, `data-audit-header`, `data-audit-orphans` (from `core/audit.typ`) — audit is triggered via `config.audit: true`, not by direct call

**What stays public:**
- `project-doc` — the entry point
- All section functions (via components imports, see TODO-1)
- `badge`, `card`, `data-table`, `metric`, `progress-bar` — themed UI primitives
- `raw-card`, `raw-badge`, `raw-data-table`, `raw-metric`, `raw-progress-bar` — raw primitives for power users
- `format-date`, `format-money`, `format-percent` — formatters
- All `link-to-*` and `*-label` functions from `refs.typ` — cross-reference utilities
- `compute-context`, `find-orphans`, `audit-missing`, `audit-summary`, `calc-budget`, `calc-requirements`, `sum-costs` — compute layer public functions
- `orphan-check`, `missing-fields`, `audit-builder` — validator convenience wrappers

**Done when:** `lib.typ` exports no symbol prefixed with `_`, no state machinery, no theme internals, no resolve internals, no audit render functions.

---

### TODO-3 — Fix `resolver.typ`: extract `_walk-dict` to eliminate 3× duplicated loop

**File:** `src/theme/resolver.typ`

**Problem:** `resolve-token` walks a dot-separated path through three different dicts (user brand, preset tokens, default tokens) using three independent `for` loops with the same logic. This is the same duplication that was fixed in `resolve.typ` via `_walk`, but `resolver.typ` cannot import from `core/resolve.typ` (that would create a dependency from `theme/` into `core/` which could eventually become circular).

**Fix:** Define a private `_walk-dict` function at the top of `resolver.typ`. It takes a dict and a pre-split parts array and returns `(found: bool, value: any)`. `resolve-token` calls it three times — once per fallback level — replacing the three loops with three single-line calls.

**Contract:** `_walk-dict` is private to `resolver.typ`. It is never exported. It does not depend on folio-state or any other folio module.

**Done when:** `resolve-token` contains zero `for` loops. The three fallback levels are each expressed as a single `_walk-dict` call. Behavior is identical — verify with branding-demo.typ compiling across all three presets.

---

### TODO-4 — Fix `compute.typ`: delete dead backward-compat aliases and flat-array branch

**File:** `src/compute.typ`

**Problem A — Dead aliases (lines 334–336):**
```
// Keep old aliases for backward compatibility with any consumers
#let sum-budget-lines = line-subtotal
#let sum-extra-costs  = extras-total
```
No backwards compat. These aliases exist for a hypothetical prior consumer that doesn't exist. Delete both lines and the comment.

**Problem B — Flat-array branch in `calc-budget` (lines 109–111):**
```
if type(budget) == array {
  let total = budget.fold(...)
  return (line-subtotal: total, extra-total: 0.0, grand-total: total)
}
```
This handles the old `(description, amount)` flat budget shape. That shape was removed from all examples when backwards compat was dropped. This branch is dead code. Delete it. `calc-budget` now only handles the dict shape — if `budget` is not a dictionary, return the zero-result tuple.

**Done when:** `compute.typ` contains no aliases and no flat-array branch. `lib.typ` no longer exports `sum-budget-lines` or `sum-extra-costs` (update TODO-2 accordingly).

---

### TODO-5 — Fix `audit.typ`: use `nonempty` instead of reimplementing path-walk

**File:** `src/core/audit.typ`

**Problem:** The `check-path` function inside `data-audit-header` implements its own dot-path walking loop — a manual `for` over `path.split(".")` — instead of calling `nonempty(data, path)` which already exists and is already imported at the top of `audit.typ`.

The result is: `nonempty` is imported but unused, and `check-path` is a duplicate of it.

**Fix:** Replace the body of `check-path` with two calls: `nonempty(data, path)` for the "Present/Empty" distinction and `_walk(data, path).found` for the "Missing" distinction. Or simplify: use `nonempty` directly in the `render-group` lambda and delete `check-path` entirely.

**Secondary problem — `folio-orphans` import source:** `data-audit-orphans` reads `folio-orphans` state. Verify that `folio-orphans` is imported from `core/refs.typ`. This is a semantic coupling problem — orphan state belongs to the ref system, but audit renders it. This is acceptable for v0.0.1 (the coupling is intentional: audit renders what refs accumulates). Document this in a comment. Do not restructure it — that's v0.1.0.

**Done when:** `check-path` is deleted, `nonempty` is used directly, the import of `nonempty` is used (not dead), and `audit.typ` compiles without warnings.

---

### TODO-6 — Resolve the requirements/budget SSOT ambiguity (explicit decision required)

**Files:** `src/components/planning.typ`, `src/compute.typ`, `docs/SCHEMA.md`, `docs/MANIFEST.md`

**Problem:** The manifest says "the data is the document" and SSOT is Principle 1. But `baselines.requirements` and `baselines.financials.budget.line_items` can describe the same physical items written twice. `find-orphans` validates the `req_id` link between them — but doesn't prevent duplication. This is an open design decision that has been deferred twice and must be resolved before v0.0.1 ships.

**Two paths — choose one explicitly:**

**Path A — Unify:** Requirements gain optional cost fields (`qty`, `unit_cost`, `unit`, `currency`). The `budget()` component reads `baselines.requirements` filtered to items with cost data, grouped by category, computing subtotals via `compute.line-subtotal`. `baselines.financials.budget` becomes config-only: `(currency, contingency_pct, extra_costs)` — no `line_items`. This eliminates duplication at the schema level. Breaking change to data.typ files — update examples by hand.

**Path B — Separate with explicit declaration:** Keep requirements and budget as separate arrays. Document in MANIFEST.md under a new "Schema Decisions" section that this is intentional: requirements express what must be delivered; budget expresses financial allocation. The `req_id` link is the traceability mechanism; duplication is the user's responsibility. Add an audit check that warns (not errors) when a budget item's `req_id` matches a requirement with `unit_cost > 0` and the amounts differ — surfacing accidental drift.

**[ASSUMPTION]** Based on alignment history (Q1.B, "those are different things") and the fact that `find-orphans` already validates `req_id` links, Path B is the correct choice for v0.0.1. Requirements = what; budget = how much. They serve different sections with different rendering needs. The SSOT principle applies to each entity being written once within its domain — not that two conceptually different things must be the same dict.

**Required actions for Path B:**
1. Add an audit check in `compute.typ` → `find-orphans` (or a new `audit-cost-drift` function) that detects when a budget item's `req_id` has `unit_cost` in the requirement and the amounts differ.
2. Add a "Schema Decisions" section to `docs/MANIFEST.md` documenting why separate arrays are correct.
3. Update `docs/SCHEMA.md` to clarify that `req_id` on budget items is the traceability link, not a derivation source.

**Done when:** The decision is explicit in MANIFEST.md, the audit detects cost drift between linked items, and `SCHEMA.md` is unambiguous about the two-array design.

---

### TODO-7 — Fix `ui.typ`: `progress-bar` default intent resolves to magenta

**File:** `src/theme/ui.typ`

**Problem:** `progress-bar` in `ui.typ` has `intent: "primary"` as its default parameter. But `palette.intent.primary` does not exist in any brand pack — `palette.primary` exists (the brand primary color), but `palette.intent.primary` does not. Any call to `progress-bar()` without an explicit intent will hit the magenta debug fallback `rgb("#ff00ff")`.

**Fix:** Change the default to `intent: none`. In the function body, resolve the fill color as: if `intent != none` use `resolve-token(st, "palette.intent." + intent)`, else use `resolve-token(st, "palette.primary")`. This makes `progress-bar()` with no intent use the brand primary color, which is the correct visual behavior.

**Done when:** `examples/branding-demo.typ` renders progress bars in brand primary color (not magenta) when called without an explicit intent.

---

### TODO-8 — Fix `cover()`: hardcoded type sizes bypass brand tokens

**File:** `src/components/initiation.typ`

**Problem:** The `cover()` component uses hardcoded `3em` and `1.5em` text sizes directly:
```
text(size: 3em, weight: "bold")[#name]
text(size: 1.5em, style: "italic")[#desc]
```

These bypass the brand token system. On the `minimal` preset (body size 11pt), `3em` renders differently than on `academic` (body size 10pt). The cover should use `typography.size.xl` for the project name and `typography.size.lg` for the description — resolved through `resolve-token` — so that the academic preset's oversized `xl: 2.4em` renders a properly large cover title.

**Fix:** Import `folio-state` and `resolve-token` in `initiation.typ` (already imported for other components). In `cover()`, resolve `st` from state and use `resolve-token(st, "typography.size.xl")` and `resolve-token(st, "typography.size.lg")` for the two text sizes.

**Done when:** `branding-demo.typ` shows visually distinct cover typography between the three brand presets.

---

### TODO-9 — Fix `data-audit`: make it non-trivially useful or remove it

**File:** `src/core/audit.typ` and `src/lib.typ`

**Problem:** `data-audit` is a one-liner that calls `data-audit-header()` and nothing else. It's exported from `lib.typ` but adds zero value over calling `data-audit-header` directly. It was probably meant to be a convenience that runs both the header dashboard and the orphan report together, but it only runs one.

**Two options:**

**Option A — Make it real:** `data-audit()` calls `data-audit-header()` followed by `data-audit-orphans()`. It becomes the single "run full audit" function. Remove `data-audit-header` and `data-audit-orphans` from `lib.typ` exports (they're internal rendering steps); export only `data-audit`.

**Option B — Delete it:** Remove `data-audit` from `audit.typ` and from `lib.typ`. The audit is triggered internally by `config.audit: true` in `project-doc` — users never call `data-audit()` directly. Having it as a public export implies a use case that doesn't exist.

**[ASSUMPTION]** Option B is correct. The audit is not user-callable — it's an internal diagnostic triggered by config. Remove `data-audit`, `data-audit-header`, and `data-audit-orphans` from `lib.typ` exports. They remain in `audit.typ` as internal functions called by `orchestrator.typ`.

**Done when:** `lib.typ` exports no audit render functions. Audit behavior is unchanged (triggered by `config.audit: true`). `data-audit` function is deleted from `audit.typ`.

---

### TODO-10 — Sync `docs/SCHEMA.md`: remove aspiration, reflect reality

**File:** `docs/SCHEMA.md`

**Problem:** Field entries still carry `Status: New` or `Status: Enhanced` labels that were written when SCHEMA.md was a spec. Every field is now implemented. These labels are stale documentation.

**Changes required:**
1. Change all `Status: New` → remove the Status line entirely (all fields are now current).
2. Change all `Status: Enhanced` → remove the Status line entirely.
3. Remove any "Alignment / Assumptions / Out of Scope" preamble sections — they were planning context, not reference docs.
4. Add a "Schema Decisions" subsection that references the requirements/budget two-array decision (from TODO-6).
5. Verify every schema path in SCHEMA.md has a corresponding entry in `src/core/schema.typ`. If any are missing or mismatched, fix `schema.typ` — it's the ground truth.

**Done when:** SCHEMA.md reads as a current reference, not a forward-looking spec. No Status fields. No alignment preamble. Every path in `schema.typ` documented in SCHEMA.md.

---

### TODO-11 — Sync `docs/BRAND.md`: document `palette.text` token

**File:** `docs/BRAND.md`

**Problem:** The `palette.text` token was added to all three brand packs (corporate: `#0f172a`, academic: `#1a1a1a`, minimal: `#212121`) as part of the `black` literal fix in `ui.typ`. But `BRAND.md`'s token reference table for `palette` does not list `palette.text`.

**Fix:** Add `palette.text` to the palette token table with type `color` and description "Primary text color (used for metric values, body copy without explicit intent)".

**Done when:** Every token that exists in brand packs appears in `BRAND.md`'s token reference.

---

### TODO-12 — Final: verify `just local` sync is correct

**File:** `justfile`

**Action:** After all code changes, run `just local` and verify:
- `~/.local/share/typst/packages/local/folio/0.0.1/src/theme/brand-packs/` exists and contains `academic.typ`, `corporate.typ`, `minimal.typ`.
- `~/.local/share/typst/packages/local/folio/0.0.1/src/compute.typ` exists and is non-empty.
- The dead `brand-packs/` root rsync include has been removed (from the previous fix round).

This is a verification task, not a code change. If the previous fix landed correctly, this should pass immediately.

**Done when:** `@local/folio:0.0.1` resolves correctly from a consumer file in a different directory.

---

## 5. Trade-off Analysis

### DECISION 1: requirements/budget — separate arrays vs. unified items

**OPTIONS:**
- **A. Unified items** — requirements gain cost fields; `budget()` reads requirements. True SSOT. Breaking schema change.
- **B. Separate arrays with `req_id` traceability** — requirements = what; budget = how much. Two arrays, one link field, audit detects drift.
- **C. Defer** — leave ambiguous; document nothing. Ship v0.0.1 with the problem unresolved.

**CHOSEN:** B.

**REASON:** Requirements and budget serve different rendering contexts, different stakeholder audiences, and different update cadences. A regulatory requirement has no cost; a budget line item may cover multiple requirements. Forcing them into one dict conflates two distinct project artifacts. The `req_id` link provides traceability without conflating semantics. The drift audit catches accidental inconsistency. Principle 1 (SSOT) means each artifact is written once in its correct location — not that all project artifacts must share a single dict.

**REVISIT IF:** A project type emerges where every requirement maps 1:1 to a budget line item and users are repeatedly writing the same item twice. At that point, an optional `use-requirements-as-budget: true` config flag (not a schema change) could derive budget from requirements automatically.

---

### DECISION 2: public API surface — minimal vs. generous

**OPTIONS:**
- **A. Minimal** — export only `project-doc` and the UI primitives. Everything else is internal.
- **B. Generous** — export everything that might be useful for custom pipelines (section fns, compute fns, ref fns, resolve utilities, state machinery).
- **C. Curated** — export `project-doc`, section functions, UI primitives, formatters, ref link functions, and compute functions. Draw a hard line at state/theme/resolve internals.

**CHOSEN:** C.

**REASON:** Section functions are legitimately public — users building custom pipelines need them. Compute functions are legitimately public — users building custom sections may want `calc-budget` or `find-orphans`. Ref link functions are legitimately public — users writing custom sections need `link-to-req` etc. But state machinery (`folio-state`, `folio-init`), resolve internals (`_walk`, `nonempty`, `resolve`), and theme internals (`resolve-token`, `resolve-spacing`) are implementation details. Exporting them is a promise that their interface won't change — a promise folio shouldn't make for v0.0.1 internals.

**REVISIT IF:** A power user needs `resolve-token` for a deeply custom component. At that point, promote it to public API with a documented contract (v0.1.0).

---

### DECISION 3: `resolve-token` — local helper vs. shared `_walk`

**OPTIONS:**
- **A. Share `_walk` from `core/resolve.typ`** — import it into `resolver.typ`. Creates a `theme/` → `core/` dependency.
- **B. Local `_walk-dict` in `resolver.typ`** — small code duplication, no cross-layer dependency.
- **C. Keep three loops** — status quo, no change.

**CHOSEN:** B.

**REASON:** A `theme/` → `core/` import creates a dependency from the styling layer into the data layer. In the current architecture, `theme/resolver.typ` is imported by `theme/ui.typ`, which is imported by `components/`, which imports from `core/`. The `core/` → `theme/` direction doesn't exist — introducing `theme/` → `core/` keeps the graph acyclic only by coincidence, not by design. A 6-line local `_walk-dict` function costs nothing and keeps the dependency graph clean. This is not meaningful code duplication — it's appropriate encapsulation.

**REVISIT IF:** `_walk-dict` diverges from `_walk` (e.g., one gets error handling the other doesn't). At that point, extract to a shared utility module that both can import without circular risk.

---

### DECISION 4: `data-audit` function — keep vs. delete

**OPTIONS:**
- **A. Keep and expand** — `data-audit()` calls both `data-audit-header()` and `data-audit-orphans()`.
- **B. Delete** — audit is an internal concern triggered by `config.audit: true`; not user-callable.
- **C. Keep as-is** — one-liner alias, leave it.

**CHOSEN:** B.

**REASON:** The audit is not a user-facing function. Users don't call `data-audit()` in their consumer files — they set `config: (audit: true)` and `project-doc` handles it. Having `data-audit()` in the public API implies a use case (calling it from custom sections or consumer files) that doesn't exist and would break the document flow if someone tried it (it would render the audit dashboard mid-document, outside the expected position). Deleting it removes a confusing affordance.

**REVISIT IF:** A use case emerges for embedding audit output at a custom position in the document. At that point, make `data-audit()` a proper public function with documented positioning behavior (v0.1.0).

---

## 6. Phased Implementation Plan

### Phase A — Compile Correctness (do first, blocks everything)

**Goal:** Eliminate compile errors. After this phase, `just compile` passes with zero errors.

**Tasks:** TODO-1, TODO-2 (import layer fix and export trim)

**Dependencies:** None. These are pure `lib.typ` changes.

**Exit criteria:**
- `just compile` runs clean on all examples and fixtures.
- No import from `phases/*.typ` for section-level functions.
- No internal symbols in `lib.typ` exports.
- Consumer file `#import "@local/folio:0.0.1": project-doc` compiles without warnings.

**Risk flags:**
- [HIGH RISK] If TODO-1 is wrong about which functions moved where, other compile errors will surface. Read `phases/initiation.typ` before touching `lib.typ` to confirm current exports.

---

### Phase B — Dead Code Elimination (do second)

**Goal:** Remove all dead code. After this phase, every line of code in `src/` is reachable.

**Tasks:** TODO-4 (compute.typ aliases + flat branch), TODO-5 (audit.typ check-path), TODO-9 (data-audit function)

**Dependencies:** Phase A must pass first (imports must be correct before we can safely delete exports).

**Exit criteria:**
- `compute.typ` has no aliases and no flat-array branch.
- `audit.typ`'s `check-path` is deleted; `nonempty` is used directly.
- `data-audit` is deleted from `audit.typ` and removed from `lib.typ`.
- `just test` still passes (no regressions).

**Risk flags:**
- Verify `audit-style` task doesn't scan `audit.typ` in a way that flags the danger color usage in `data-audit-header`. The danger color derives from `resolve-token` (correct) — not a hardcoded literal.

---

### Phase C — Implementation Correctness (do third)

**Goal:** Fix behavioral bugs. After this phase, the rendered output is visually correct.

**Tasks:** TODO-3 (resolver.typ `_walk-dict`), TODO-7 (progress-bar intent), TODO-8 (cover typography)

**Dependencies:** Phase A (must compile). Phase B (no dead code to reason around).

**Exit criteria:**
- `resolve-token` has no `for` loops — three `_walk-dict` calls instead.
- `progress-bar()` with no intent renders in brand primary color, not magenta.
- `cover()` title and description sizes differ visually between the three brand presets.
- `branding-demo.typ` PDF visually confirmed for all three presets.

**Risk flags:**
- `_walk-dict` in `resolver.typ` must be a private function (not exported). Verify `lib.typ` doesn't accidentally re-export it.
- After changing `cover()` to use token-resolved sizes, verify the academic preset's `xl: 2.4em` doesn't produce an absurdly large cover title. Adjust the academic `xl` token if needed.

---

### Phase D — Design Decision & Documentation (do fourth)

**Goal:** Resolve the one open design question and sync all docs to reality.

**Tasks:** TODO-6 (requirements/budget SSOT decision), TODO-10 (SCHEMA.md), TODO-11 (BRAND.md)

**Dependencies:** Phase C (all code is correct before docs are synced).

**Exit criteria:**
- MANIFEST.md has a "Schema Decisions" section documenting the two-array choice and why.
- SCHEMA.md has no Status fields, no alignment preamble, and documents `req_id` traceability semantics.
- BRAND.md documents `palette.text` in the token table.
- `find-orphans` (or a new helper) detects cost drift between linked requirement/budget items.
- `just test` still passes.

**Risk flags:**
- The cost-drift audit check must not generate false positives for cases where a budget item intentionally prices differently from the requirement (e.g., bulk discount). Consider making it a "warning" severity in the audit, not a compile error.

---

### Phase E — Final Verification (done)

**Goal:** Confirm v0.0.1 is shippable.

**Tasks:** TODO-12 (local sync verification) + full visual review

**Dependencies:** Phases A–D complete.

**Exit criteria (full checklist):**
- [ ] `just test` passes clean (zero errors, zero warnings)
- [ ] `just audit-style` passes (zero hardcoded color literals in scanned paths)
- [ ] `just compile` compiles all 34 source files + all examples + all fixtures
- [ ] `just local` syncs correctly; brand packs present at target path
- [ ] `examples/branding-demo.typ` PDF reviewed visually — three distinct presets confirmed
- [ ] `examples/full-standards.typ` PDF reviewed visually — all 28 sections present
- [ ] `tests/fixtures/empty-data.typ` — compiles, shows only `_missing()` placeholders
- [ ] `tests/fixtures/minimal-data.typ` — compiles, renders only populated sections
- [ ] `tests/fixtures/partial-data.typ` — compiles, audit dashboard shows gaps
- [ ] `tests/fixtures/full-data.typ` — compiles, all sections render
- [ ] `cover()` typography is visually distinct between presets
- [ ] `progress-bar()` renders in brand primary, not magenta
- [ ] `lib.typ` exports zero symbols prefixed with `_`
- [ ] `lib.typ` exports zero state/theme/resolve internals
- [ ] MANIFEST.md documents the requirements/budget two-array decision
- [ ] SCHEMA.md has no Status fields or alignment preamble
- [ ] BRAND.md documents `palette.text`
- [ ] No Spanish strings anywhere in `src/`
- [ ] `compute.typ` has no aliases and no flat-array branch

---

## 7. Implementation Management

### Execution Order (strict)

```
Phase A: TODO-1 → TODO-2
    ↓
Phase B: TODO-4 → TODO-5 → TODO-9
    ↓
Phase C: TODO-3 → TODO-7 → TODO-8
    ↓
Phase D: TODO-6 → TODO-10 → TODO-11
    ↓
Phase E: TODO-12 → visual review
```

Within each phase, tasks are independent and can be done in any order. Between phases, the order is strict — don't start Phase B until `just compile` is clean.

### Critical Path

`TODO-1 → TODO-2 → just compile clean` is the critical path. Everything else depends on the imports being correct. If TODO-1 gets the import layer wrong, every subsequent `just compile` will lie about what's broken.

### Integration Points (highest risk)

1. **`lib.typ` + `phases/*.typ` + `components/*.typ`**: The three-layer import chain (lib → phase → component) is where TODO-1 operates. A mistake here produces misleading error messages because Typst import errors don't always identify the root cause.

2. **`audit.typ` + `refs.typ` + `orchestrator.typ`**: The orphan state (`folio-orphans`) is defined in `refs.typ`, accumulated by `safe-link` in `refs.typ`, read by `data-audit-orphans` in `audit.typ`, and triggered by `orchestrator.typ` when `config.audit == true`. This three-file chain must remain consistent after TODO-5 and TODO-9.

3. **`compute.typ` + `planning.typ`**: After TODO-4 removes the flat-array branch from `calc-budget`, verify that `planning.typ`'s `budget()` component still produces correct output. It calls `compute.line-subtotal` and `compute.extras-total` directly — it doesn't go through `calc-budget` — so this is likely fine, but worth a compile check.

### Breaking Changes in This Round

All changes in this TODO are internal refactors or export surface reductions. No user-facing schema changes (Path B for TODO-6). No new config keys. No new section functions. A user with a consumer file that imports from `lib.typ` using only the public API (as documented) will see zero breaking changes.

---

## 8. Validation & Testing Strategy

| Layer | Test Type | What it verifies | Trigger |
|---|---|---|---|
| Import layer | Compile | `lib.typ` resolves all imports correctly | `just compile` |
| Dead code | Compile | No unreachable imports produce warnings | `just compile` |
| Style audit | Static scan | No hardcoded color literals in components/primitives/ui | `just audit-style` |
| Compute logic | Compile + fixture | Budget totals correct; orphan detection fires on broken refs | `just compile` + `full-data` fixture |
| Token resolution | Visual review | `branding-demo.typ` shows 3 distinct presets; no magenta | Manual PDF review |
| Cover typography | Visual review | Cover title sizes differ between presets | Manual PDF review |
| Missing data | Compile + fixture | `empty-data.typ` and `partial-data.typ` show placeholders, don't crash | `just compile` |
| Public API contract | Compile | Consumer file using only public exports compiles with zero warnings | `just compile` |
| Local sync | File system | Brand packs present at Typst local package path | `just local` + manual verify |
| Full flow | Compile + visual | `full-standards.typ` renders all 28 sections | `just test-full` + PDF review |

### Local Dev Workflow (per task)

Before marking any TODO done:
1. `just audit-style` — catches color literals immediately.
2. `just compile` — catches import errors and compile failures.
3. If the task touches rendering: `just test-brand` or `just test-full` + open PDF.
4. `just test` — full suite before committing.

### Architecture Fitness Functions (currently implemented)

- `audit-style` enforces no hardcoded color literals in component/primitive/ui code.
- `find-orphans` enforces cross-reference integrity at runtime (audit dashboard).
- `audit-missing` enforces schema completeness at runtime (audit dashboard).
- Section guards enforce graceful degradation — no section crashes on missing data.

---

## 9. Open Questions & Risks

**1. Does Typst 0.14.2 support all patterns used?**
`_walk-dict` uses standard dict access and pattern matching — no exotic features. Safe. `folio-orphans` state accumulation across multiple `safe-link` calls relies on Typst's state update semantics working correctly in a multi-pass compile context — this is known to work but the second-compile caveat in `audit.typ` is real.

**2. Will `just audit-style` catch literals inside `audit.typ`?**
The current audit scans `src/components/`, `src/primitives/`, `src/theme/ui.typ`, and `src/core/`. `audit.typ` is in `src/core/` — so yes, it will be scanned. The danger color in `data-audit-header` derives from `resolve-token` (correct, not literal). But verify that `block(stroke: 4pt + danger, fill: danger.lighten(90%))` in the audit header doesn't use a literal — it uses the locally resolved `danger` variable which came from `resolve-token`. The audit regex pattern matches the word "danger" as a named color — but in this context `danger` is a variable name, not a color literal. The regex `\bdanger\b` would false-positive here. **This needs a targeted check** — either confirm the regex only matches `danger` as a standalone token in a color position, or add a `# audit-style: ignore` comment pattern to the audit script for intentional exceptions.

**3. Academic preset `xl: 2.4em` — is it visually appropriate for cover?**
This is the old `01` size-title value. At 10pt body, `2.4em` = 24pt for the cover title. That's appropriate for an academic cover page. But verify visually before calling it done.

**4. The `extra-sections` pipeline mutation in `orchestrator.typ`:**
The orchestrator mutates `current-pipeline` inside a loop using `.insert()`. In Typst, arrays are immutable — `.insert()` returns a new array, it doesn't mutate in place. This means `current-pipeline.insert(idx, record)` may be silently doing nothing if the return value isn't captured. This is a pre-existing potential bug (not introduced by this TODO) but worth verifying during Phase E visual review by actually injecting a custom section and confirming it appears in the correct position.