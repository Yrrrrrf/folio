# folio v0.0.1 — Implementation Plan

> Companion to `MANIFEST.md`. The manifest is the *why*; this is the *how*.
>
> **Audience**: a senior engineer (or LLM agent) executing the v0.0.1 completion. **Style**: spec-driven, zero-code, opinionated. Every recommendation justifies *what / how / why*, and is calibrated for a 10-year shelf life.

---

## 0. Executive Summary

folio v0.0.1 is a Typst package that turns a project's data dictionary into a publication-grade PMBOK-aligned document via a single show-rule call. The architecture already in place — declarative state, layered token resolver, data-driven pipeline, graceful fallback — is sound; the remaining work is finishing what's half-built and locking the contract before users arrive. The design bet is that durability comes from a tiny stable public API (one orchestrator function plus four phase-level callables), a single canonical schema (no adapters, no normalizers), and customization expressed as data (config dicts, brand dicts, section records) rather than code patches. That bet pays off at year 5 when a brand redesign is a 30-line dict instead of a fork, and at year 10 when extending PMBOK to ISO 21500 vocabulary requires re-labelling, not rewriting.

---

## 1. Context & Constraints

### Restated context
- **Project state**: existing Typst package at v0.0.1, ~70% architecturally complete. Single repo, no monorepo. Pre-release, no external consumers.
- **Goal**: complete v0.0.1 such that any project's data — when written in folio's canonical schema — renders cleanly via `#show: project-doc(data)` with no per-project boilerplate.
- **Team & scale**: single author with LLM-agent assistance. Document compile times must remain sub-30s. Output is static PDF.
- **Methodology stance**: PMBOK 7-aligned, intentionally compatible with ISO 21500 and PRINCE2 via shared skeleton.

### Architectural rules
- Typst 0.14.2 compiler.
- Single source of truth: one canonical schema, one shape, no adapters or normalizers.
- All identifiers, comments, headings, and built-in vocabulary in English.
- Snake_case for data keys (project authors write data); kebab-case for Typst function names.
- Show-rule pattern preserved as the consumer-facing entry point.
- Public API is small and stable; everything else is internal and unstable.

### Out of scope
- Internationalization (RTL, locale-aware months, currency code switching).
- Interactive PDF features (forms, JS, hyperlink overlays beyond Typst native).
- Multi-volume PDF output.
- Methodology-specific forks (PRINCE2-vocabulary fork, ISO 21500 fork).
- Live data sources or runtime data fetching.

### Assumptions [all confirmed in intake]
- [ASSUMPTION] Project 01 is reshaped to fit folio's canonical schema, not the reverse.
- [ASSUMPTION] Verification is empirical: compile-clean + manual inspection + optional snapshot.
- [ASSUMPTION] Pre-1.0 means breaking changes are free; only project 01 currently consumes folio.
- [ASSUMPTION] User-supplied formatters (`format-money`, `format-date`) are the only locale escape hatch.

---

## 2. Architecture Overview

```
┌─────────────────────────────────────────────────────┐
│  PUBLIC API  (src/lib.typ)                          │
│  project-doc · folio-init · initiation · planning · │
│  execution · closure · section fns · primitives ·   │
│  format-money · format-date · ref helpers           │
└──────────────────────┬──────────────────────────────┘
                       │
┌──────────────────────┴──────────────────────────────┐
│  ORCHESTRATION                                      │
│  pmbok-pipeline (records) · section-guard           │
│  phase composition · pipeline filter & inject       │
└──────────────────────┬──────────────────────────────┘
                       │
┌──────────────────────┴──────────────────────────────┐
│  CORE                                               │
│  state · schema · resolve · audit · refs · fallback │
└──────────────────────┬──────────────────────────────┘
                       │
┌──────────────────────┴──────────────────────────────┐
│  PHASE RENDERERS                                    │
│  initiation · planning · execution · closure        │
│  (each = level-1 heading + filtered pipeline iter)  │
└──────────────────────┬──────────────────────────────┘
                       │
┌──────────────────────┴──────────────────────────────┐
│  THEME                                              │
│  tokens (defaults) · resolver (brand overlay) ·     │
│  ui adapters (token-aware primitive wrappers)       │
└──────────────────────┬──────────────────────────────┘
                       │
┌──────────────────────┴──────────────────────────────┐
│  PRIMITIVES                                         │
│  card · data-table · badge · metric · progress-bar  │
└─────────────────────────────────────────────────────┘
```

### Domain split
- **Core domain**: PMBOK document structure — the canonical schema, the pipeline, the audit registry, the cross-reference system. Changes here are the most consequential.
- **Supporting domains**: theme/branding, primitives, formatters. These can evolve more freely; they don't change document semantics.

### Composition flow
1. Consumer writes `data` (one dict) and calls `#show: project-doc(data, config, brand)` — or one of the phase callables for partial documents.
2. `project-doc` calls `folio-init` to populate state, then renders: audit header (if enabled) → cover → TOC → phase fns in order → audit appendix (if enabled).
3. Each phase fn emits its level-1 heading and iterates the pipeline filtered by phase, calling `section-guard` per record.
4. `section-guard` consults the `auto`/bool toggle from config, calls `nonempty(data, path)` to decide, and either renders or skips.
5. Section render functions read from state, call `resolve(data, path)` for each field, and emit content using token-aware UI adapters. Missing fields render as `missing("path")` markers.

---

## 3. Design Patterns & Code Standards

For each major layer, the pattern, justification, structural description, and standards.

### State container
**Pattern**: singleton state via Typst's native `state()`.
**Why**: section and component functions can be invoked anywhere in a document — top-level, inside other Typst content, in user-appended sections. Threading `(data, config, brand)` through every call would force every section into a 3-argument signature and pollute consumer code. State decouples invocation site from data source.
**How**: a single `folio-state` (key: `"folio-state"`) holds the record `(data, config, brand)`. The public `folio-init(data, config, brand)` show-rule populates it. All section and audit functions read from it inside `context {}` blocks.
**Standards**: state reads only inside `context`; no mutation outside `folio-init`; key namespace prefix `folio-` for any auxiliary state (e.g. `folio-orphans`).
**3y/5y/10y**: Typst's `state()` API is stable and unlikely to change. Risk at scale: state-coupling makes section fns hard to invoke without prior `folio-init`. Acceptable trade — it's the same pattern used by every Typst template package in the ecosystem.

### Declarative pipeline
**Pattern**: data-driven dispatch — the document is a list of records, not a sequence of imperative calls.
**Why**: adding, removing, or reordering sections becomes a data edit. Custom section injection is appending a record. Audit registry derives from the pipeline. The pipeline is introspectable (you can ask folio "what sections exist?" without parsing source).
**How**: each pipeline entry is a record with fields `(phase, section-id, data-path, render-fn)`. The orchestrator walks the list, filters by phase or `extra-sections` injection rules, and calls `section-guard(toggle, path, render-fn)` per entry. The pipeline lives in `core/orchestrator.typ` as a top-level constant.
**Custom injection**: the user supplies `config.extra-sections` as a list of records `(id, phase, after | before, data-path, render)`. The orchestrator inserts each at the named anchor before iteration. Anchoring by section-id (not numeric index) keeps user injections stable when the default pipeline shifts.
**Standards**: pipeline records are immutable values; section IDs are unique across built-ins and user injections (collision = compile-time `panic` with clear message). The pipeline order *is* the document order — there is no separate "ordering" concept.
**3y/5y/10y**: a closed pipeline ages badly because users hit edge cases the maintainer didn't predict. An open, anchor-injected pipeline accommodates new methodologies (PRINCE2 product descriptions, ISO 21500 stakeholder register) without requiring upstream changes.

### Section guard
**Pattern**: strategy with three behaviors keyed on toggle value.
**Why**: section visibility has three orthogonal concerns (force-render, force-skip, render-if-data) that need a uniform interface; if-else chains in the orchestrator would scatter the policy across 15 sites.
**How**: `section-guard(toggle, path, render-fn)` where toggle is `true` (always render, even with missing data — produces heading + `missing` markers), `false` (always skip), or `auto` (the default — render iff `nonempty(data, path)`).
**Standards**: every section in the pipeline goes through `section-guard`. No section function calls itself; the orchestrator owns dispatch.

### Schema-as-data
**Pattern**: the canonical schema is a list of records, not a type definition.
**Why**: Typst has no static type system, so a "type-style" schema would be unenforced documentation. A records-as-data schema is enforced by being *consumed* — the audit reads it for the registry, the docs are generated from it, the pipeline derives section paths from it. Drift between consumers is mechanically prevented because they share a source.
**How**: `core/schema.typ` exports `folio-schema` as a list of records `(path, severity, phase, kind)` where `kind` ∈ `{string, dict, array, number}` (documentary). The audit registry filters by severity, the pipeline derives `data-path` per section, the docs render the table.
**Standards**: every data field that any section function reads must have a corresponding schema record. New fields are added to the schema first; section functions reading unschema'd paths are a lint failure.
**3y/5y/10y**: at year 3, this prevents the divergence the original CONCERNS.md flagged (registry says `baselines.financials.budget`, code reads `line_items`). At year 10, it's the foundation for an external schema renderer (HTML docs, JSON Schema export, etc.) without touching package internals.

### Path resolution with explicit fallback
**Pattern**: dotted-path reader returning either the value or a visible missing marker.
**Why**: a typo in a data path (`bsaelines.scope`) shouldn't crash the document; it should produce a red marker pointing at the typo, exactly where the data would have rendered. This makes data errors discoverable in the output, not hidden in stack traces.
**How**: `resolve(data, path, fallback-name)` walks the dot-separated path; if any segment is missing or the terminal value is `none`/`""`/`(:)`, returns `missing(fallback-name or path)`. Companion `nonempty(data, path)` returns a bool for guard decisions.
**Standards**: section functions never `data.at(...)`-chain manually; they always go through `resolve`. The `missing` marker (renamed from `_missing`) is internal-rendering-only and not a public concept users invoke.

### Theme overlay
**Pattern**: layered token resolution — brand overrides defaults, missing-everywhere returns a visible sentinel.
**Why**: branding shouldn't require forking the package or rewriting components. Users override the tokens they care about; defaults fill the rest. A magenta sentinel for unknown token names makes typos immediately visible in the output.
**How**: `resolve-token(state, "palette.primary")` first walks `state.brand.<path>`; if found returns it; otherwise walks `default-tokens.<path>`; if also missing returns `rgb("#ff00ff")`. `resolve-spacing(state, multiplier)` combines base spacing × density × multiplier.
**Standards**: every component style attribute (color, spacing, radius, font size) goes through `resolve-token` or `resolve-spacing`. No hardcoded colors, sizes, or measurements in primitives or section functions. Tokens are namespaced by domain (`typography.*`, `palette.*`, `geometry.*`, `spacing.*`).

### Cross-reference system with orphan registry
**Pattern**: tagged label factories + context-aware lookup + orphan side-channel.
**Why**: risks reference WBS tasks, issues reference risks, etc. Hardcoded `link()` calls crash on missing IDs. We need: (a) graceful degradation per cell, AND (b) a record of what was orphaned so the audit appendix can list them.
**How**: each entity type exposes a label factory (`task-label(id) → label("task-<slug>")`). A `safe-link(label, fallback-text)` function checks `query(label).len() > 0` inside a `context` block; if zero, it emits the fallback text *and* registers the orphan into a `folio-orphans` state list `(label, source-section)`. The audit appendix at end-of-document iterates `folio-orphans` and renders the report.
**Standards**: section functions consume cross-refs only through `link-to-task`/`link-to-milestone`/`link-to-risk`/`link-to-issue`/`link-to-change`. Direct `link()` calls outside `core/refs.typ` are forbidden.
**[HIGH RISK]**: orphan collection depends on Typst's layout pass. The first compile pass may have an empty or partial orphan list; convergence requires a second pass. This is intrinsic to Typst's layout-deferred query model and not solvable inside the package. The orphan appendix renders at end-of-doc to maximize coverage, but users running single-pass compiles will see incomplete reports. Document this prominently.

### Audit system (split: header + appendix)
**Pattern**: registry-driven inspection emitting two document blocks at different document positions.
**Why**: users need diagnostics without that information bleeding into the production document. Two outputs are needed because of Typst's layout-pass constraint: the severity dashboard (Present/Empty/Missing per registered field) can be computed eagerly and belongs at the top for visibility; the orphan-references list can only be complete at the end of the document.
**How**:
- `data-audit-header()`: renders before the cover when `config.audit == true`. Reads schema, computes Present/Empty/Missing per record using `nonempty(data, path)`, groups by severity, emits the "DO NOT SHIP" banner + severity tables.
- `data-audit-orphans()`: renders at end-of-doc when `config.audit == true`. Reads `folio-orphans` state, emits the orphan appendix table or a "no orphans detected" note.
- Both are no-ops when audit is off.
**Custom checks**: `config.extra-checks` is a list of records `(path, severity, phase)` appended to the schema-derived registry before rendering. Same record shape as the canonical schema for consistency.
**Standards**: audit fns only render conditionally on `config.audit == true`. Severity buckets are exactly `{critical, important, recommended}` — fixed taxonomy, not user-extensible (extending severity creates documentation drift).

### Pluggable formatters
**Pattern**: function-pointer override via state config.
**Why**: currency and date formatting vary by project (MXN vs USD, English vs Spanish months, comma vs period decimal separators). Folio ships English/USD-shaped defaults but cannot predict every locale. Providing a function override is more flexible than a config dict because users can implement arbitrary formatting (e.g., `"$1,234.56 MXN"`, `"17 de febrero de 2026"`).
**How**: `format-money(amount)` reads `state.config.format-money` (a function); if present, calls it; else uses the built-in default (English/USD-shaped). Same for `format-date(date-str)`. The override receives the raw value and returns content.
**Standards**: every section function rendering money or dates calls `format-money`/`format-date`, never inline formatting. Defaults are documented as "English-shaped" and users requiring locale-correct output are expected to provide overrides.
**[ASSUMPTION]**: amount inputs to `format-money` are numeric (int or float); date inputs to `format-date` are ISO-shaped strings (`YYYY-MM-DD`). Schema enforces this through the `kind` field; non-conforming inputs produce a `missing` marker rather than a crash.

### Primitives + UI adapters (two-layer separation)
**Pattern**: pure styling primitives wrapped by token-aware UI adapters.
**Why**: primitives (`card`, `data-table`, `badge`, `metric`, `progress-bar`) need to be invokable in isolation for advanced users building custom layouts; they cannot depend on state. UI adapters apply the active theme and are what section functions actually call. Two layers cleanly separate "styling logic" from "theming logic."
**How**: primitives in `src/primitives/` take styling args directly (`card(body, bg, border-color, pad, rad, title-size)`). UI adapters in `src/theme/ui.typ` are token-aware shadows of each primitive (`card(body, title)` reads state and resolves all styling tokens). Section fns import from `theme/ui.typ`; advanced users can import from `primitives/` for raw control.
**Standards**: primitives never read state, never resolve tokens, never know the schema. UI adapters never define their own styling — they only resolve tokens and pass through.

### Naming, casing, and module conventions
- **Data keys** (project author-facing): snake_case (`status_report`, `risk_register`, `lessons_learned`). These are what users write in their `data.typ`.
- **Typst function and module names**: kebab-case (`project-doc`, `format-money`, `data-table`, `safe-link`). Idiomatic Typst.
- **Internal helpers**: kebab-case, no leading underscore. Privacy is enforced by *not exporting from `lib.typ`*, not by naming convention. The leading-underscore convention from the current codebase is dropped.
- **File names**: kebab-case. All Spanish file names (`inicio`, `planificacion`, `ejecucion`, `cierre`) are renamed to English (`initiation`, `planning`, `execution`, `closure`).
- **Comments**: English everywhere.

### Public API surface (lib.typ exports — closed list)
- **Orchestration**: `project-doc`, `folio-init`.
- **Phase fns**: `initiation`, `planning`, `execution`, `closure`.
- **Section fns**: `cover`, `pitch`, `business-case`, `objectives`, `boundaries`, `milestones`, `budget`, `gantt`, `team`, `status-report`, `risk-matrix`, `issue-log`, `change-log`, `lessons-learned`, `sign-off`.
- **Audit**: `data-audit-header`, `data-audit-orphans`.
- **UI adapters**: `card`, `data-table`, `badge`, `metric`, `progress-bar`.
- **Primitives** (advanced): re-exported under `raw-card`, `raw-data-table`, etc., to avoid name collision with adapters.
- **Formatters**: `format-money`, `format-date`.
- **Refs**: `task-label`, `milestone-label`, `risk-label`, `issue-label`, `change-label`, `link-to-task`, `link-to-milestone`, `link-to-risk`, `link-to-issue`, `link-to-change`.
- **Resolution helpers** (for custom section authors): `resolve`, `nonempty`, `missing`, `section-guard`, `resolve-token`, `resolve-spacing`, `folio-state`.

Anything not in this list is internal. Versioning of the public API begins at v0.1.0; v0.0.x carries no stability guarantee.

---

## 4. Component Map & Directory Structure

```
folio/
├── typst.toml                    # package manifest
├── README.md                     # quickstart + 5-line example
├── MANIFEST.md                   # the why (companion doc)
├── CHANGELOG.md                  # release history
├── docs/
│   ├── manual.typ                # rendered user reference
│   └── schema.md                 # canonical schema reference
├── src/
│   ├── lib.typ                   # public API surface — re-exports only
│   ├── core/
│   │   ├── state.typ             # folio-state, folio-init
│   │   ├── schema.typ            # canonical schema records (NEW)
│   │   ├── orchestrator.typ      # pipeline + project-doc + phase fns
│   │   ├── guard.typ             # section-guard
│   │   ├── resolve.typ           # resolve, nonempty, get-title
│   │   ├── audit.typ             # header + orphan appendix + extra-checks
│   │   ├── refs.typ              # labels + safe-link + folio-orphans
│   │   └── fallback.typ          # missing marker (renamed from _missing)
│   ├── phases/
│   │   ├── initiation.typ        # phase fn + section fns (renamed)
│   │   ├── planning.typ          # phase fn + section fns (renamed)
│   │   ├── execution.typ         # phase fn + section fns (renamed)
│   │   └── closure.typ           # phase fn + section fns (renamed)
│   ├── primitives/
│   │   ├── card.typ
│   │   ├── data-table.typ        # renamed from data_table.typ
│   │   ├── badge.typ
│   │   ├── metric.typ
│   │   └── progress-bar.typ      # renamed from progress_bar.typ
│   ├── theme/
│   │   ├── tokens.typ
│   │   ├── resolver.typ
│   │   └── ui.typ
│   └── utils/
│       └── formatters.typ
├── examples/
│   ├── minimal.typ               # sparsest viable project
│   ├── project-01.typ            # reshaped UAEMéx telecom project
│   ├── thesis.typ                # academic thesis project
│   ├── rfp.typ                   # commercial RFP response
│   └── components/               # per-section isolated demos
└── tests/
    ├── fixtures/                 # compile-clean test inputs
    ├── snapshots/                # reference PDFs (binary)
    └── README.md                 # how to run snapshot tests
```

### Component responsibilities (one sentence each)

| Component | Responsibility | Must NOT |
|---|---|---|
| `lib.typ` | Re-export the public API surface. | Contain logic. |
| `core/state.typ` | Own `folio-state` and the `folio-init` show-rule. | Render anything. |
| `core/schema.typ` | Define the canonical schema as records. | Depend on rendering or theme. |
| `core/orchestrator.typ` | Own the pipeline, `project-doc`, phase fns; handle injection. | Define styling. |
| `core/guard.typ` | Dispatch render/skip per toggle. | Read schema directly. |
| `core/resolve.typ` | Walk dotted paths, return value or `missing`. | Render content. |
| `core/audit.typ` | Compute and render the audit header and orphan appendix. | Modify state. |
| `core/refs.typ` | Provide label factories, `safe-link`, orphan registry. | Render section content. |
| `core/fallback.typ` | Render the `missing(name)` marker. | Know about the schema. |
| `phases/<name>.typ` | Define one phase fn + that phase's section render fns. | Import another phase's internals. |
| `primitives/*.typ` | Pure styling functions. | Read state, resolve tokens, know the schema. |
| `theme/tokens.typ` | Default token tree (data only). | Have logic. |
| `theme/resolver.typ` | Resolve tokens with brand overlay. | Know about the schema. |
| `theme/ui.typ` | Token-aware wrappers around primitives. | Render schema-driven content. |
| `utils/formatters.typ` | `format-money`, `format-date` with override support. | Know about schema or theme. |

---

## 5. Trade-off Analysis

### DECISION 1: State-coupled section functions vs. parameter-passed
**Options considered**:
- A. State-coupled (current): section fns read from `folio-state` inside `context`. Pros: clean call sites, idiomatic Typst, no parameter explosion. Cons: cannot invoke without prior `folio-init`; harder to unit-test.
- B. Parameter-passed: every section fn takes `(data, config, brand)`. Pros: pure, testable, no implicit dependencies. Cons: 3-arg signatures everywhere, painful for users invoking individual sections.
- C. Hybrid: state-coupled by default, with a second variant accepting explicit args. Pros: both worlds. Cons: doubled API surface, two ways to do the same thing.
**CHOSEN**: A.
**Why**: Typst conventions favor state, the consumer ergonomics are vastly better, and "unit testing" Typst is impractical anyway — testing happens at the snapshot level, where state-coupling is irrelevant. Parameter-passing provides theoretical purity for no practical gain.
**Revisit if**: Typst grows a static type system or a property-test framework that makes parameter-passed pure functions meaningfully easier to verify.

### DECISION 2: Schema-as-data vs. schema-as-types
**Options considered**:
- A. Schema-as-data (records consumed by audit/pipeline/docs).
- B. No schema — section fns own their data-paths individually; audit registry is a separate hardcoded list.
- C. Schema-as-types — declare expected types and validate at runtime.
**CHOSEN**: A.
**Why**: B is the current state and produces the exact bug the user flagged (registry says `budget`, code reads `line_items`). C is wasted effort in Typst — no compiler enforcement means the validation runs as boilerplate at every render. A makes drift mechanically impossible: change one record, and the pipeline + audit + docs all update.
**Revisit if**: Typst gains compile-time type checking, in which case C becomes viable.

### DECISION 3: Single audit dashboard vs. split (header + orphan appendix)
**Options considered**:
- A. Single first-page dashboard (current). Pros: high visibility. Cons: orphan refs cannot be reported (Typst layout-pass constraint).
- B. Single end-of-doc dashboard. Pros: complete. Cons: "DO NOT SHIP" banner is the *last* thing readers see — easily missed.
- C. Split: severity table on first page, orphan appendix at end. Pros: best of both — banner up top, complete data at end.
**CHOSEN**: C.
**Why**: severity (Present/Empty/Missing) is computable eagerly and belongs where it can scare a user out of shipping a stub. Orphans require post-layout completion and belong wherever they can be complete — that's the end. Splitting acknowledges Typst's reality without compromising visibility.
**Revisit if**: Typst's layout/query model changes to allow eager cross-reference resolution. (Unlikely.)

### DECISION 4: Custom-section injection by anchor vs. by index
**Options considered**:
- A. By index (`extra-sections: ((position: 5, ...),)`). Pros: simple. Cons: any change to the default pipeline breaks every user's index assumptions.
- B. By anchor (`extra-sections: ((after: "boundaries", ...),)`). Pros: stable across pipeline reorderings. Cons: requires unique anchor IDs.
- C. Free-form append after `project-doc` (no injection mechanism). Pros: simplest. Cons: cannot reorder relative to built-ins; cannot insert *between* phases.
**CHOSEN**: B.
**Why**: at year 3 the pipeline will have grown; index-based injection would silently break consumers. Anchor-based injection is forward-compatible by construction. The uniqueness constraint is enforced at compile-time with a clear panic message.
**Revisit if**: never — this is a stable design choice.

### DECISION 5: Formatter overrides as functions vs. config dicts
**Options considered**:
- A. Function pointers (`config.format-money: my-fn`). Pros: maximum flexibility (locale, currency, decimals). Cons: opaque to introspection.
- B. Config dicts (`config.money: (symbol: "$", thousands-sep: ",", ...)`). Pros: introspectable, declarative. Cons: cannot express arbitrary formats (e.g., "17 de febrero de 2026").
- C. Hybrid: ship structured options for common cases, accept function override for advanced cases.
**CHOSEN**: A.
**Why**: i18n is out of scope, so the structured options of B are wasted complexity. The function-pointer is a 5-line override for any project that needs it. C is half-built i18n in disguise.
**Revisit if**: i18n comes back into scope, in which case C becomes the right call.

### DECISION 6: Phase functions — lightweight vs. show-rule closures
**Options considered**:
- A. Show-rule closures (`#show: initiation(data, config, brand)`). Pros: symmetric with `project-doc`. Cons: re-initializes state per call; calling two phases double-initializes.
- B. Lightweight content blocks (`#initiation()` after `folio-init`). Pros: matches existing component pattern; multiple phases compose naturally. Cons: requires explicit `folio-init` first.
- C. Both modes supported.
**CHOSEN**: B.
**Why**: confirmed in intake — phase fns are lightweight, sharing the same state once initialized. Composing two phases is then `folio-init(data) + initiation() + planning()` with no double-init. `project-doc` is the wrapper that handles initialization for the all-phases case.
**Revisit if**: never under v0.x; would only be reconsidered with a different state model.

### DECISION 7: Identifier casing — snake everywhere vs. snake-data + kebab-code
**Options considered**:
- A. All kebab-case, including data keys (`status-report`, `risk-register`).
- B. Snake_case data keys, kebab-case Typst code.
- C. Snake_case everywhere (current code mixes both, but skews snake).
**CHOSEN**: B.
**Why**: data keys are authored by humans typing project data and align with JSON/YAML/Python conventions, where snake_case is dominant. Typst code conventions favor kebab-case. The split is intuitive — *what's data follows data conventions; what's code follows code conventions*. Mixing creates a small mental load but matches user expectations.
**Revisit if**: Typst community converges on a single casing standard (currently it does not).

### DECISION 8: Verification strategy — compile-clean + snapshot
**Options considered**:
- A. Compile-clean only (smoke tests). Pros: cheap. Cons: silent visual regressions.
- B. Compile-clean + PDF snapshot (manually approved baselines). Pros: catches both crash and visual regressions. Cons: snapshot maintenance overhead.
- C. Property-based testing of pure functions. Pros: rigorous. Cons: most folio fns are not pure; would only cover ~20% of the surface.
**CHOSEN**: B.
**Why**: B is the only strategy that catches the regressions users actually care about (visual breakage). C is theoretically appealing but practically misaligned with Typst's nature. A is the floor — necessary but insufficient.
**Revisit if**: Typst gains a native testing framework with first-class snapshot support.

---

## 6. Phased Implementation Plan

Five phases, each independently shippable and verifiable.

### Phase 1 — Naming pass + Schema as code
**Goal**: lock the public API and the schema before anything else moves.
**Components**:
- Rename Spanish files (`inicio` → `initiation`, `planificacion` → `planning`, `ejecucion` → `execution`, `cierre` → `closure`).
- Drop leading underscores from public-facing names (`_resolve` → `resolve`, `_money` → `format-money`, `_date` → `format-date`, `_missing` → `missing`).
- Normalize file names to kebab-case (`data_table.typ` → `data-table.typ`, `progress_bar.typ` → `progress-bar.typ`).
- Convert all Spanish comments to English.
- Create `core/schema.typ` with the canonical schema as records.
- Refactor `core/audit.typ` to read from `core/schema.typ` instead of its own hardcoded `pmbok-registry`.
- Refactor `core/orchestrator.typ` so its `pmbok-pipeline` either is generated from the schema or references schema records.
- Update `lib.typ` to the closed export list defined in §3.
**Dependencies**: none (this is the foundation).
**Exit criteria**:
- Every existing example compiles after rename.
- A grep for Spanish strings (`inicio`, `cierre`, etc.) in `src/` and `examples/` returns no matches outside example data content.
- Audit and pipeline both reference `core/schema.typ`; `pmbok-registry` no longer exists as a duplicate constant.
- `lib.typ` exports exactly the surface listed in §3.
**Risk flags**: the rename pass is mechanical but wide; missing one import will surface at compile time. Mitigated by exit criterion #1.

### Phase 2 — Phase callables + Pipeline filter + Custom-section injection
**Goal**: expose `initiation`/`planning`/`execution`/`closure` as public phase fns, and enable custom-section injection.
**Components**:
- In each `phases/<name>.typ`, add a phase-level fn that emits the level-1 phase heading and iterates the pipeline filtered by phase via `section-guard`.
- Refactor `project-doc` to compose: audit-header → cover → TOC → `initiation()` → `planning()` → `execution()` → `closure()` → audit-appendix → user body.
- Implement `extra-sections` injection: orchestrator merges built-in pipeline with user-supplied records before iteration; anchor resolution by section ID; collision check with clear panic.
- Document the phase-fn calling pattern (lightweight, requires prior `folio-init`).
**Dependencies**: Phase 1 schema.
**Exit criteria**:
- A consumer file using only `initiation()` after `folio-init` compiles and renders only the initiation phase, with the level-1 heading.
- A consumer file using `extra-sections` to inject a custom section after `boundaries` renders the custom section in the correct position.
- ID collisions between built-in and custom sections panic with a message naming the offending ID.
- `project-doc` produces visually identical output to a manual `folio-init + cover + TOC + initiation + planning + execution + closure + appendix` sequence (snapshot equivalence).
**Risk flags**: phase fn composition order must match `project-doc`'s composition exactly. Mitigated by snapshot equivalence test in exit criteria.

### Phase 3 — Audit completion (orphan registry + appendix)
**Goal**: fix the orphan-refs gap flagged in CONCERNS.md.
**Components**:
- Add `folio-orphans` state (key: `"folio-orphans"`) holding a list of records `(label, source-section)`.
- Modify `safe-link` in `core/refs.typ`: on `query(label).len() == 0`, push to `folio-orphans` in addition to emitting fallback text.
- Implement `data-audit-orphans()` in `core/audit.typ`: reads `folio-orphans` at end-of-doc, renders the orphan table or "no orphans detected" note.
- Split `data-audit()` into `data-audit-header()` (severity dashboard, runs before cover) and `data-audit-orphans()` (runs at end).
- `project-doc` calls header at start and appendix at end when `config.audit == true`.
- Implement `extra-checks`: `config.extra-checks` is concatenated with the schema's audit registry before rendering.
- Document the layout-pass caveat: orphan list converges on second compile pass.
**Dependencies**: Phase 1 schema, Phase 2 orchestrator.
**Exit criteria**:
- A fixture document with a deliberate orphan reference (e.g. risk references `WBS-99` which doesn't exist) compiles, the safe-link emits fallback, and the orphan appendix at end-of-doc lists the orphan with correct source attribution.
- `extra-checks: ((path: "governance.advisor", severity: "critical", phase: "meta"),)` causes the audit header to flag `governance.advisor` as missing.
- Audit is fully no-op when `config.audit == false`.
**Risk flags**:
- [HIGH RISK] orphan list completeness depends on layout pass — single-pass compiles will under-report. Mitigation: documentation, plus snapshot test runs Typst with `--diagnostic-format` to verify pass count.
- Adding state mutation in `safe-link` requires it to be inside `context`; ensure all current call sites are inside context blocks.

### Phase 4 — TOC + Pluggable formatters
**Goal**: complete the document chrome and lock the formatter override mechanism.
**Components**:
- In `project-doc`, after cover, before phase iteration, emit Typst's native `outline(title: "Table of Contents", indent: auto, depth: 3)`.
- Refactor `format-money` and `format-date` to read `state.config.format-money` / `state.config.format-date` (function pointers); call if present, else use built-in default.
- Document the override signatures (input shape, expected output content type).
- Update existing examples to demonstrate at least one project supplying overrides.
**Dependencies**: Phase 2 orchestrator (for project-doc composition).
**Exit criteria**:
- `project-doc` output has a TOC after cover with depth-3 entries for phases (level-1) and sections (level-2).
- Setting `config.format-money: my-fn` causes all money rendering to use `my-fn`; default is unaffected if not set.
- Same verified for `format-date`.
- An example showing custom MXN formatting compiles and renders `"$X,XXX.XX MXN"` (or similar).
**Risk flags**: TOC depth and styling rely on Typst's `outline()` defaults; brand overrides for TOC styling are out of scope for v0.0.1.

### Phase 5 — Examples, snapshot harness, schema docs
**Goal**: prove the satisfaction criterion ("any project compiles cleanly") and lock the verification loop.
**Components**:
- Reshape `examples/project-01.typ` into folio's canonical schema with full data (every section populated for the UAEMéx telecom project).
- Author `examples/thesis.typ` and `examples/rfp.typ` as second and third proofs of the schema's universality.
- Author `examples/minimal.typ` showing the sparsest viable project (just `project.name`).
- Build `tests/` directory: `tests/fixtures/` holds `.typ` files; `tests/snapshots/` holds reference PDFs; `tests/README.md` documents the workflow (`typst compile → manual approve → store snapshot → diff on subsequent runs`).
- Generate `docs/schema.md` from `core/schema.typ` records (manual at first; automation deferred to post-1.0).
- Update `README.md` quickstart to the final 5-line example.
**Dependencies**: Phases 1–4 complete.
**Exit criteria**:
- All four examples compile cleanly with no `missing` markers in the production output (audit off).
- Each example with `audit: true` produces a header dashboard and orphan appendix.
- `tests/fixtures/` includes at least: minimal (sparse), project-01 (full), missing-field cases (deliberate gaps), orphan-ref cases (deliberate broken refs).
- `docs/schema.md` lists every path the section functions consume.
- `README.md` quickstart, when copy-pasted, compiles a 1-page valid PDF.
**Risk flags**: reshaping project 01 may surface schema gaps not anticipated. Treat each gap as a Phase 1 schema amendment, not a workaround.

---

## 7. Implementation Management

### Sequencing (dependency order)
```
Phase 1 (rename + schema)
       │
       ▼
Phase 2 (phase fns + injection)
       │
       ├─────────────┐
       ▼             ▼
Phase 3 (audit)   Phase 4 (TOC + formatters)
       │             │
       └──────┬──────┘
              ▼
      Phase 5 (examples + snapshots)
```
Phases 3 and 4 are parallelizable after Phase 2 completes.

### Critical path
Phase 1 → Phase 2 → Phase 5 is the critical path. Any delay here cascades to v0.0.1 release. Phases 3 and 4 can slip individually without blocking 5 (a v0.0.1 with audit-header-only and no TOC would still be shippable, just less complete).

### Integration points (high-coordination zones)
- **Phase 1 ↔ all later phases**: the schema record shape locked in Phase 1 is consumed everywhere. Get this right; backtracking is expensive.
- **Phase 2 orchestrator ↔ Phase 3 audit ↔ Phase 4 TOC**: composition order in `project-doc` is `audit-header → cover → TOC → phases → audit-appendix → body`. All three phases touch this ordering; serialize the edits.
- **Phase 5 example reshaping ↔ Phase 1 schema**: amendments must round-trip through Phase 1, not be patched in.

### Breaking changes (flagged explicitly)
- **[BREAKING]** All Spanish file names (`inicio`, `planificacion`, `ejecucion`, `cierre`) renamed. Anyone importing these directly breaks.
- **[BREAKING]** Public API names with leading underscores (`_resolve`, `_money`, `_date`, `_missing`) renamed. Any consumer using these breaks.
- **[BREAKING]** `pmbok-registry` constant removed; consumers should not have been reading this.
- **[BREAKING]** Section IDs in pipeline records may change snake_case → kebab-case for *config keys* (e.g. `config.sections.status_report` → `config.sections.status-report`) — if the rename applies. Decide explicitly in Phase 1: keep section IDs snake_case (matching data keys) or move them to kebab (matching Typst code). My recommendation: keep section IDs snake_case — they're identifiers a user types, like data keys, and the consistency with `data.execution.status_report` is more valuable than the consistency with `data-table`.

### Ownership
For a single-author + LLM-agent setup, ownership is sequential per phase. The user reviews each phase exit criteria manually before the next phase begins. The agent has no authority to skip exit criteria.

---

## 8. Validation & Testing Strategy

### Per-layer verification
| Layer | Test type | What it verifies |
|---|---|---|
| Schema records | Inspection | All paths used by section fns are registered. |
| Resolve / nonempty | Fixture | Path resolution returns expected values; missing paths produce `missing` markers. |
| Section guard | Fixture | `auto`/`true`/`false` produce expected render/skip behavior. |
| Section render fns | Snapshot | Output matches reference PDF byte-for-byte (or visually, on inspection). |
| Phase fns | Snapshot | Phase composition renders correct level-1 heading + section sequence. |
| `project-doc` | Snapshot | Full document composition matches reference. |
| Audit header | Fixture + snapshot | Severity counts match expected; "DO NOT SHIP" banner present. |
| Orphan registry | Fixture (2-pass) | Deliberate orphans appear in appendix; non-orphans don't. |
| Theme resolver | Fixture | Brand overrides win over defaults; missing tokens produce magenta sentinel. |
| Custom-section injection | Fixture | Section appears at correct anchor; collision panics. |
| Formatter overrides | Fixture | Custom `format-money` is invoked; default used when absent. |

### Architecture fitness functions
These are mechanical checks enforcing architectural rules; they run as part of the test harness:
- **No Spanish identifiers**: grep `(inicio|cierre|ejecucion|planificacion)` against `src/`; any match is a fail.
- **No leading underscores in `lib.typ` exports**: parse `lib.typ` import names; any starting with `_` is a fail.
- **No hardcoded colors in section/phase fns**: grep `rgb\(` against `src/phases/`; any match is a fail (hardcoded styling violates the theme overlay pattern).
- **Schema-pipeline parity**: every `data-path` in the pipeline corresponds to a schema record; assert in a fixture.
- **No direct `link()` in section fns**: grep `link\(` against `src/phases/`; matches must go through `link-to-*` helpers.

### Local dev validation (developer per-PR loop)
1. `typst compile examples/minimal.typ` — sparsest case must compile.
2. `typst compile examples/project-01.typ` — full case must compile.
3. `typst compile examples/thesis.typ` and `examples/rfp.typ` — alternate cases must compile.
4. Run the snapshot diff harness: any fixture whose output PDF differs from the stored snapshot is flagged for manual review.
5. Run fitness greps (above).

### Observability
This is a static document generator; runtime observability is minimal. What we track instead:
- **Compile time** per example (sub-30s budget; alarm if exceeded).
- **Compile pass count** (Typst convergence; if any fixture takes more than 3 passes, investigate).
- **Warning count** during compile (Typst emits warnings for unused content; track and minimize).

---

## 9. Risks

- **[HIGH RISK] Orphan registry layout-pass dependency.** Single-pass compiles produce incomplete orphan reports. Cannot be solved in-package; must be documented. Mitigation: README + audit appendix both note "run twice for accurate orphans."
- **[HIGH RISK] Schema record shape lock-in.** The schema record shape `(path, severity, phase, kind)` is consumed by audit, pipeline, and docs. Changing it post-1.0 ripples through all three. Mitigation: spend Phase 1 carefully; review the schema with the manifest before locking.
- **[REVISIT] Section ID casing.** The recommendation (keep snake_case for section IDs to match data keys) is judgement-based; there's a reasonable counter-argument for kebab. Lock the choice in Phase 1 and document the rationale; do not mix.
- **[MEDIUM RISK] Custom-section anchor collision UX.** A panic with a clear message is the design — but if the message isn't clear, debugging is painful. Test the panic path explicitly with deliberate collisions in a fixture.
- **[MEDIUM RISK] Brand overlay typo silent fallback.** A typo'd token name returns the magenta sentinel `#ff00ff`. This is intentional (visible failure mode) but may surprise users who assume their brand applied. Document the sentinel behavior in `MANIFEST.md` and in brand examples.
- **[LOW RISK] Typst compiler version pinning.** `typst.toml` declares `compiler = "0.14.2"`. Typst's upgrade cadence is fast; an upgrade may break syntax. Mitigation: pin in the manifest, test against the next minor version before upgrading.
- **[LOW RISK] Snapshot maintenance burden.** As fixtures grow, manually re-approving snapshots scales poorly. Acceptable at v0.0.1 fixture count (~10); revisit if fixtures exceed ~30.

---

## Appendix — Definition of Done for v0.0.1

The release is shippable when **all** of the following hold:

1. Five examples (`minimal`, `project-01`, `thesis`, `rfp`, plus one component demo) compile cleanly with no `missing` markers in production output.
2. The same five examples with `config.audit: true` produce both header dashboard and orphan appendix, with at least one example deliberately containing an orphan to exercise the appendix.
3. Custom-section injection works: a fixture using `extra-sections` renders the custom section at the correct anchor.
4. Phase callables work standalone: a consumer using only `initiation()` after `folio-init` produces a valid partial document.
5. `format-money` and `format-date` overrides take effect when supplied; defaults render when not.
6. TOC renders after cover, depth 3, with phase headings and section headings.
7. All architecture fitness function checks pass.
8. `docs/schema.md` matches the records in `core/schema.typ` (manual confirmation acceptable for v0.0.1).
9. `README.md` quickstart, copy-pasted, compiles a valid PDF.
10. No Spanish identifiers remain anywhere in `src/` or example *code* (example *content* in Spanish is fine).

When this list is satisfied, folio v0.0.1 ships and the manifest's friend-test holds.