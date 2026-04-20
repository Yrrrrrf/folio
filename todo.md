# Folio v0.0.1 — Documentation & README Implementation Plan

*Architect Spec Planner output · English · zero-code · opinionated · 10-year horizon*

---

## 0. Executive Summary

Folio is a state-driven project management document generator written in Typst. Its public surface currently ships two organisms (`charter`, `status-report`) backed by a six-namespace data contract (`metadata`, `initiation`, `baselines`, `registers`, `governance`, `closure`) mapped to PMBOK® 7 and PRINCE2® 7. The repository lacks the documentation layer needed to turn working code into an adopted package: the README is generic, Typst Universe maintainer feedback is unaddressed, and `docs/manual.typ` is a stub. This plan delivers two artifacts — a redesigned `README.md` and a multi-chapter Typst manual shipped as `docs/manual.pdf` — structured so that (1) project managers unfamiliar with Typst can onboard from either entry point, (2) every narrative beat is grounded in a specific PMBOK/PRINCE2 citation, (3) the two existing organisms each earn a rendered showcase inside the two capital deep-dive chapters. The design is opinionated about one architectural bet: **a single shared fixture project threads through the entire manual**, proving Folio's central thesis (one `dt.typ` → many documents) without ever having to assert it.

---

## 1. Context & Constraints

### Project state (from actual tree)
Folio v0.0.1 "Reborn" is live with:
- Six-namespace architecture implemented in `src/contract/namespaces/` (all six files present).
- Two rendering organisms in `src/kinds/`: `charter.typ`, `status-report.typ`, plus `_manifest.typ`.
- Sections layer (`src/sections/`) partitioned by namespace (baselines, closure, governance, initiation, metadata, registers).
- Nine design primitives (`src/primitives/`): badge, callout, card, heading, metric, progress-bar, signature-line, table, timeline-bar.
- Shell layer (`src/shell/`): cover-page, project-page, toc.
- Theme tokens, typography, presets, and one palette (`formal`).
- Runtime i18n: `en-US`, `es-MX`.
- Four examples: `00-smoke`, `01-minimal`, `02-report`, `03-degraded`.
- `docs/manual.typ` exists as a stub.

### Goals
1. Ship a GitHub `README.md` that reads as a professional package front page, communicates the PMBOK/PRINCE2 thesis in 30 seconds, and addresses Typst Universe maintainer feedback (`docs/` absent, no compiled manual).
2. Ship a multi-chapter Typst manual under `docs/` that teaches Folio to a PM audience, respects the static/dynamic dichotomy of the six-namespace architecture, and culminates each capital chapter in a live render of an existing organism.

### Audience
- **Primary:** project managers with no Typst experience who need to ship formal PM documents for anything from a 2-section school project to an enterprise engagement.
- **Secondary:** Typst-literate developers curious about the package internals.

### Scale & 10-year horizon
Single package, single maintainer today. Documentation must absorb a third organism, a second palette, and new namespace fields without structural rewrites for at least 3–5 years; the architecture should remain coherent at 10 years even if the organism count triples.

### Hard constraints
- English only throughout the manual and README. Folio's runtime i18n (`en-US`, `es-MX`) is a *runtime* capability; prose documentation stays English-only for v0.0.1.
- Showcases render **only** organisms that exist today (`charter`, `status-report`). No vaporware.
- Must respect Typst Universe packaging rules: `docs/` excluded from the published tarball via `typst.toml`; the compiled `manual.pdf` is a repo artifact, not a package artifact.

### Out of scope for this plan
- Standalone markdown reference pages (`docs/overview.md`, `docs/architecture.md`, etc.) — deferred; the manual is the single canonical documentation deliverable for this round.
- A documentation website (mdBook, Zola, etc.).
- Spanish translation of the manual.
- Internal source code refactors. This plan touches only `README.md`, `docs/*`, and `typst.toml`.

### Assumptions
- [ASSUMPTION] The six namespaces are stable in v0.0.1 and will not be renamed before the first tagged release.
- [ASSUMPTION] The `charter` and `status-report` organisms accept a project dictionary that includes namespaces they do not themselves consume; `examples/03-degraded.typ` implies graceful degradation is a supported capability, and the shared fixture relies on this.
- [ASSUMPTION] `manual.pdf` will be committed to the repo as a binary artifact and linked from the README.
- [ASSUMPTION] `typst.toml` currently lacks an `exclude` key; adding one will not break an existing publish flow.

---

## 2. Architecture Overview

Documentation is a **two-surface product**: a **GitHub surface** (README.md rendered on the repo landing page) and a **PDF surface** (manual.pdf, a self-contained book). The two surfaces funnel to the same conceptual content but serve different reading postures — the README is scanned in 30 seconds, the manual is read in 30 minutes.

```
                ┌─────────────────────────────┐
                │         README.md           │
                │  30-second pitch, badges,   │
                │  quick start, links out     │
                └──────────────┬──────────────┘
                               │
                 ┌─────────────┴──────────────┐
                 ▼                            ▼
       ┌──────────────────┐        ┌────────────────────┐
       │ docs/manual.pdf  │◀───────│  docs/manual.typ   │
       │ (compiled book)  │ built  │   (orchestrator)   │
       └──────────────────┘ from   └──────────┬─────────┘
                                              │ #include
                                              ▼
              ┌──────────────────────────────────────────┐
              │            docs/chapters/                │
              ├──────────────────────────────────────────┤
              │ Part I   — Orientation                   │
              │   ch01-getting-started.typ               │
              │   ch02-foundations.typ                   │
              │ Part II  — Document Control              │
              │   ch03-metadata.typ                      │
              │ Part III — The Contract  (static)    ★   │
              │   ch04-the-contract.typ  → charter       │
              │ Part IV  — The Execution (dynamic)   ★   │
              │   ch05-the-execution.typ → status-report │
              │ Part V   — Project Close                 │
              │   ch06-closure.typ                       │
              │ Part VI  — Reference                     │
              │   ch07-reference.typ                     │
              └──────────────────────────────────────────┘
                                   │
                  imports shared project data
                                   ▼
                  ┌─────────────────────────────────┐
                  │ docs/chapters/_fixture.typ      │
                  │ "Aurora Cloud Migration" —      │
                  │ the single project that threads │
                  │ through every chapter           │
                  └─────────────────────────────────┘
```

**Core domain.** The chapter orchestration and the shared fixture.
**Supporting domains.** Cover page, TOC, crosswalk callouts — reuse Folio's own `src/shell/` and `src/primitives/` layers (dog-food the package).

---

## 3. Design Patterns & Code Standards

### 3.1 Progressive Disclosure *(whole manual)*
**Pattern.** Information is revealed in widening spirals: first *what you do* (Ch 1), then *why it's built this way* (Ch 2), then *the full schema* (Ch 3–6), then *the appendix* (Ch 7). A reader can stop at any chapter boundary and still have a usable mental model.
**Why.** The PM audience is non-homogeneous — some will only ever need Chapter 1; senior PMs will read Chapters 4–5 to evaluate Folio's seriousness against their standards.
**Year 3 / 5 / 10.** Still correct. Progressive disclosure is a fundamental doc pattern, not a fashion. At year 10, even if the book doubles in length, each new chapter slots into an existing tier.

### 3.2 Shared Fixture *(chapters 2–6)*
**Pattern.** One `_fixture.typ` file defines a complete sample project ("Aurora Cloud Migration"). Every narrative chapter from Ch 2 onward imports from it rather than inventing local examples.
**Why.** This *is* the thesis of Folio — one `dt.typ`, many documents. Asserting it in prose is weak; demonstrating it with identical data rendering two different artifacts in Chapters 4 and 5 is unarguable.
**How applied.** `_fixture.typ` exports a single `project` dictionary. Chapter snippets pull slices (`project.initiation.pitch`) for inline callouts; end-of-chapter showcases pass the whole `project` to the organism.
**Standard.** Fixture must include *all six namespaces fully populated* with realistic Aurora data. Partial fixtures would undermine the graceful-degradation story that Chapter 3 teaches.
**Year 3 / 5 / 10.** Fixture grows richer as optional fields land, never narrower. Breaking schema changes force a coordinated update — this is a known cost (§5, decision #2) and exactly why centralization wins.

### 3.3 Showcase-At-The-End *(chapters 04, 05)*
**Pattern.** Capital chapters build the conceptual case across the chapter body, then close with `#charter(project)` or `#status-report(project)` rendered inline. The rendered document becomes part of the manual's own pages.
**Why.** The reader's last impression of each capital chapter is a real rendered artifact, not an abstract schema.
**Standard.** Showcase renders are the *only* place the manual invokes organism functions. Non-capital chapters teach data, not rendering.

### 3.4 Standard Crosswalk *(every chapter opening)*
**Pattern.** Every chapter opens with a two-line crosswalk box: *"PMBOK® 7 reference: §X.X"* / *"PRINCE2® 7 theme: <name>"*. Implemented by reusing `src/primitives/callout.typ` — we dog-food Folio's own primitives in its own documentation.
**Why.** Establishes authority in 200ms. A PM scanning the manual knows whether the book takes the standards seriously.
**Standard.** Every crosswalk must cite a specific section/theme — no generic "follows PMBOK" hand-waving.

### 3.5 Two-Door Redundancy *(README ↔ Manual)*
**Pattern.** `README.md` §Quick Start and `ch01-getting-started.typ` intentionally duplicate the *minimal viable* onboarding flow. Both produce a working render in under five minutes.
**Why.** The GitHub reader and the PDF reader are different people in different contexts. Forcing one to read the other breaks flow.
**Standard.** When the two diverge in content, the README gets the update first (it's the shop window); the manual chapter follows within the same PR.

### 3.6 Dog-Food The Package *(manual.typ only)*
**Pattern.** `docs/manual.typ` uses Folio's own `src/shell/cover-page.typ`, `src/shell/toc.typ`, and `src/theme/presets.typ` to lay itself out.
**Why.** If the manual looks amateur, users won't trust Folio to produce their charters. Using Folio on Folio forces us to eat our own cooking.
**Standard.** Manual must not import any layout primitive the package does not publicly export.

### 3.7 Code & Content Standards
- **Naming.** Chapter files: `chNN-kebab-case.typ`. Fixture: `_fixture.typ` (underscore prefix signals "not a chapter"). Assets: `docs/assets/<kind>/<name>.ext`.
- **Dependency direction.** `docs/manual.typ` depends on `docs/chapters/*`; chapters depend on `_fixture.typ` and on `folio` (via `@preview/folio` once published, `@local/folio` during development). Chapters never depend on each other. Enforced by compile-each-chapter-alone CI step (§8).
- **Prose voice.** Second person ("you"), active voice, present tense. No "the reader will note." No marketing superlatives.
- **Line lengths.** Typst source wraps at 100 columns to keep diffs readable.
- **No hidden magic.** Every Typst `#let` a PM encounters in a snippet is explained in prose on the same page or the prior page.

---

## 4. Component Map & Directory Structure

### 4.1 Proposed tree (delta only — unchanged paths omitted)

```
folio/
├── README.md                                [REWRITE]
├── typst.toml                               [EDIT: add exclude rules]
└── docs/
    ├── manual.typ                           [REWRITE: full orchestrator]
    ├── manual.pdf                           [NEW: committed artifact]
    ├── chapters/
    │   ├── _fixture.typ                     [NEW]
    │   ├── ch01-getting-started.typ         [NEW]
    │   ├── ch02-foundations.typ             [NEW]
    │   ├── ch03-metadata.typ                [NEW]
    │   ├── ch04-the-contract.typ            [NEW]  ★ charter showcase
    │   ├── ch05-the-execution.typ           [NEW]  ★ status-report showcase
    │   ├── ch06-closure.typ                 [NEW]
    │   └── ch07-reference.typ               [NEW]
    └── assets/
        └── diagrams/                        [NEW: figures Ch 2 needs]
```

### 4.2 Components

**`README.md` — The shop window.**
*Location:* repo root.
*Responsibility:* convert a 30-second GitHub glance into either a quick-start attempt or a PDF download.
*Exposes to readers:* tagline, badges, 2-paragraph pitch, architecture snapshot (ASCII), quick-start snippet, organism↔standard matrix (5-row table), links to `docs/manual.pdf`, `LICENSE`, Typst Universe.
*Consumes:* nothing at build time — it's markdown.
*Must NOT:* duplicate the full manual, include architectural deep-dives, or leave any asserted feature unlinked to either a working example or a manual chapter.

**`docs/manual.typ` — The book's spine.**
*Responsibility:* page master, cover page, TOC, preface (1 page), ordered `#include` of every chapter.
*Exposes:* compile target that produces `docs/manual.pdf`.
*Consumes:* `src/shell/cover-page.typ`, `src/shell/toc.typ`, `src/theme/presets.typ` (see §3.6).
*Must NOT:* contain prose content. All content lives in chapters.

**`docs/chapters/_fixture.typ` — The shared project.**
*Responsibility:* define one `project` dictionary for "Aurora Cloud Migration" with every namespace fully populated with realistic data.
*Exposes:* `#let project = (...)` as the single export.
*Consumes:* nothing (pure data).
*Must NOT:* contain any rendering logic or partial/variant projects.

**`docs/chapters/ch01-getting-started.typ` — Install → first PDF in four pages.**
*Responsibility:* minimum viable onboarding. Walks through installing Folio from Typst Universe, the smallest valid `project` dictionary (only `metadata` + `initiation.pitch`), and a first `#charter(project)` compile.
*Consumes:* the `folio` package for the demo compile; does *not* import `_fixture.typ` (Ch 1 stays minimal).
*Must NOT:* introduce the six-namespace architecture — that's Chapter 2's job.

**`docs/chapters/ch02-foundations.typ` — Why six pillars.**
*Responsibility:* articulate the state-driven philosophy, the static/dynamic dichotomy, the mapping to PMBOK knowledge areas and PRINCE2 themes. Contains the single architecture diagram for the whole book. Introduces the Aurora project by name.
*Consumes:* `_fixture.typ` (first appearance).
*Must NOT:* enumerate schema fields — that's each pillar's chapter.

**`docs/chapters/ch03-metadata.typ` — The cross-cutting pillar.**
*Responsibility:* field-by-field reference of `metadata`; its audit-and-traceability role (ISO 9001, ISO 27001 for `confidentiality`); how `src/shell/project-page.typ` consumes it globally (cover, headers, footers, confidentiality stamps).
*No showcase* — `metadata` alone does not produce a document; it conditions every other rendered page.

**`docs/chapters/ch04-the-contract.typ` — ★ Static pillars + charter showcase.**
*Responsibility:* deep-dive of `initiation` and `baselines`.
- Opens with the **PMBOK *Project Charter* + PRINCE2 *Business Case*** crosswalk.
- Walks `initiation.pitch → objectives → business_case → feasibility (TELOS)`.
- Walks `baselines.scope (WBS) → schedule (milestones) → financials (BOM + contingency) → quality`.
- Closes with a full `#charter(project)` render using the Aurora fixture.
*Must NOT:* touch dynamic namespaces.

**`docs/chapters/ch05-the-execution.typ` — ★ Dynamic pillars + status-report showcase.**
*Responsibility:* deep-dive of `registers` and `governance`.
- Opens with the **PRINCE2 *Risk/Issue Registers* + PMBOK *Communications Management*** crosswalk.
- Walks `registers.assumptions_log → risk_register → issue_log → change_log`.
- Walks `governance.team → stakeholders → raci_matrix → communications → current_status (RAG)`.
- Closes with `#status-report(project)` positioned narratively as "Week 4 of the Aurora project."
*Key narrative beat:* the reader sees the *same* fixture from Ch 4 produce a *different* document. This is the book's thesis moment.

**`docs/chapters/ch06-closure.typ` — Project close.**
*Responsibility:* the `closure` namespace (acceptance_date, handover_deliverables, lessons_learned, signatures). **PMBOK *Close Project* + PRINCE2 *End Project Report*** crosswalk.
*Showcase:* intentionally none. No `closure` organism exists yet; fabricating one would violate the "show only what exists" rule. Chapter ends with an explicit *Roadmap: a `#closure-doc` organism is planned* note — honest, not apologetic.

**`docs/chapters/ch07-reference.typ` — The appendix.**
*Responsibility:*
- Full `project` schema table (field, type, required/optional, default, PMBOK/PRINCE2 citation).
- Namespace ↔ PMBOK knowledge area ↔ PRINCE2 theme crosswalk matrix.
- Glossary of PM terms used throughout the manual.
- Pointers back to `examples/00-smoke`, `01-minimal`, `02-report`, `03-degraded` in the repo.
*Reader mode:* lookup, not narrative. Tables dominate.

**`typst.toml` — Package manifest.**
*Edit scope:* add `exclude = ["docs/**", "examples/**", "*.pdf"]` (or the current equivalent per Typst packaging spec — verify before merging). Directly addresses Typst Universe maintainer feedback (saecki comments on `docs/` and `manual.pdf`).

---

## 5. Trade-off Analysis

```
DECISION: Where does the manual's prose content live?
OPTIONS CONSIDERED:
  A. Monolithic docs/manual.typ holding every chapter inline
     — pros: single file, no include mechanics, simplest mental model
     — cons: unmergeable in team PRs, 1500+ line file, no per-chapter CI
  B. Multiple chapters under docs/chapters/, imported by docs/manual.typ
     — pros: per-chapter PRs, per-chapter compile test, clear ownership,
             matches the six-pillar mental model
     — cons: one extra directory level, include ordering must be maintained
  C. Full documentation site (mdBook / Zola) generating from Typst sources
     — pros: searchable, versioned URLs, navigation
     — cons: massive infra cost, markdown↔Typst duplication, deferred value
CHOSEN: B
REASON: The six-pillar architecture is the book's structure; forcing it
        into one file denies that. Per-chapter files also let CI compile
        each chapter in isolation, which is our fitness function for
        "chapters must not depend on each other."
REVISIT IF: chapter count exceeds ~12 (at which point a website's
        navigation advantages start to matter), or if an external docs
        platform becomes a mandate.
```

```
DECISION: One shared fixture project vs. per-chapter micro-examples
OPTIONS CONSIDERED:
  A. Per-chapter examples (each chapter defines its own project data)
     — pros: chapters are truly independent; schema drift in one chapter
             doesn't cascade
     — cons: the thesis — "one dt.typ, many documents" — becomes an
             assertion instead of a demonstration
  B. Single shared _fixture.typ consumed by every chapter from Ch 2 on
     — pros: the reader literally sees the same project data produce
             charter AND status-report; schema becomes the book's
             connective tissue; simpler to evolve (update one file)
     — cons: tight coupling — a breaking schema change touches every
             chapter that uses the affected slice
  C. Hybrid: shared fixture for chapters 2–7; a minimal local example
     only in Ch 1
     — pros: pragmatic; Ch 1 stays first-success minimal without dragging
             in the full Aurora project; everywhere else demonstrates
             the thesis
     — cons: two patterns to remember (one is trivially smaller than
             the other, so cost is near-zero)
CHOSEN: C
REASON: Ch 1's job is first-success in four pages; loading the full
        Aurora fixture there is overkill. From Ch 2 onward, the shared
        fixture earns its keep. Aurora is introduced by name in Ch 2.
REVISIT IF: schema changes become frequent enough that shared-fixture
        maintenance dominates chapter-authoring time.
```

```
DECISION: Where does the compiled manual.pdf live and how is it built?
OPTIONS CONSIDERED:
  A. Committed binary at docs/manual.pdf, rebuilt manually before release
     — pros: zero CI infrastructure; anyone cloning sees the current PDF
     — cons: binary in git history; easy to forget to rebuild before tag
  B. Not committed; built in CI on release tag and attached to GH Release
     — pros: clean git history; release-bound versioning
     — cons: no PDF visible to someone browsing the repo; CI required
  C. Committed binary + pre-commit script that verifies PDF matches sources
     — pros: committed-binary convenience with drift detection
     — cons: over-engineered for a single-maintainer package at v0.0.1
CHOSEN: A
REASON: Single maintainer, early version, PM audience that wants to see
        the PDF without running Typst. Committed wins for discovery.
        typst.toml exclude ensures the binary does not bloat the package.
REVISIT IF: the manual exceeds ~2 MB compiled, or the project gets a CI
        pipeline for other reasons — at which point switch to option B
        and stop committing the binary.
```

```
DECISION: Chapter split strategy — by namespace, by organism, or by
          static/dynamic dichotomy?
OPTIONS CONSIDERED:
  A. One chapter per namespace (6 deep-dive chapters + orientation)
     — pros: clean mapping to the data model
     — cons: metadata and closure chapters would be thin; loses the
             narrative arc; no obvious home for organism showcases
  B. One chapter per organism (2 deep-dive chapters today, growing to N)
     — pros: showcase-centric; future-proof as organisms are added
     — cons: buries the namespace architecture; redundant when two
             organisms share namespaces
  C. Static/dynamic dichotomy with pillar-grouped chapters
     — pros: reflects the core architectural insight; capital chapters
             (4, 5) pair namespaces that belong together AND end with
             the organism that consumes them
     — cons: requires justifying the split to the reader (done in Ch 2)
CHOSEN: C
REASON: The data spec itself opens by declaring the static/dynamic
        separation as Folio's governing idea. The manual structure
        embodies that idea instead of sidestepping it. Secondary benefit:
        as new organisms land, they slot into the existing static or
        dynamic chapter rather than forcing a new chapter each.
REVISIT IF: a future organism spans both static and dynamic pillars
        (unlikely given current design, but possible with e.g. an
        integrated dashboard document).
```

```
DECISION: README depth — minimal landing vs. mini-manual
OPTIONS CONSIDERED:
  A. Minimal README — badges, one-paragraph pitch, quick start, links
     — pros: scannable in 30 seconds; pushes serious readers to the manual
     — cons: may undersell Folio to a casual GitHub visitor
  B. Mini-manual README — architecture deep-dive, organism catalog,
     namespace reference inline
     — pros: self-contained for someone who won't download the PDF
     — cons: duplicates the manual; drift risk; scanner fatigue
  C. Minimal README with a single "visual architecture snapshot" and an
     organism↔standard matrix table (2 concessions to depth)
     — pros: scannable AND professional-looking; the matrix communicates
             standards-compliance at a glance
     — cons: the matrix needs updating when organisms are added
CHOSEN: C
REASON: A GitHub visitor who does not open the PDF still needs to see
        "this is serious" in under a minute. The matrix is a 5-row table
        and the snapshot is one ASCII block — cheap to maintain.
REVISIT IF: organism count exceeds 8 (matrix becomes unwieldy).
```

---

## 6. Phased Implementation Plan

Each phase is independently shippable. Don't start Phase N+1 until Phase N is merged.

### Phase 1 — Foundation & Shop Window *(3–4 days)*
**Goal.** Address Typst Universe packaging feedback; deliver the README that makes Folio look ready for adoption.

**Components to build.**
- `typst.toml` — add `exclude` entry for `docs/**`, `examples/**`, `*.pdf`.
- `README.md` — full rewrite per §4 structure.
- `docs/` directory scaffolded; `docs/manual.typ` rewritten with cover, TOC, preface, and empty chapter includes. Chapters exist as 1-line stub files so `manual.typ` compiles end-to-end.

**Dependencies.** None — purely additive/replacements.

**Exit criteria.**
- `typst compile docs/manual.typ docs/manual.pdf` produces a PDF with cover + TOC + 7 placeholder chapters, no warnings.
- `README.md` renders cleanly on GitHub with all badges live and all internal links resolved.
- Dry-run package bundle shows `docs/` and `examples/` excluded; tarball size dropped accordingly.

**Risk flags.**
- [LOW] `typst.toml` exclude syntax — verify against current Typst packaging docs before merging.

### Phase 2 — Orientation *(3–4 days)*
**Goal.** A new PM can read 15 pages and understand what Folio is and how to use it.

**Components to build.** `ch01-getting-started.typ`, `ch02-foundations.typ`, `docs/assets/diagrams/` (any figures Ch 2 needs, even if initially just ASCII embedded in the Typst source).

**Dependencies.** Phase 1 merged.

**Exit criteria.**
- Each chapter compiles standalone (`typst compile docs/chapters/chNN-*.typ /tmp/chNN.pdf`).
- A reader following only Ch 1 produces a working charter PDF from a 10-line `project` dictionary.
- Ch 2 contains the six-pillar diagram and introduces the "Aurora" project by name.

**Risk flags.**
- [MEDIUM] Ch 1 is the hardest chapter to write — it must be simple without being patronizing. Plan for 2 review rounds.

### Phase 3 — The Capital Chapters *(5–7 days)* ★ core value
**Goal.** The two showcase chapters that prove the thesis, plus the metadata bridge.

**Components to build.** `_fixture.typ` (full six-namespace Aurora project), `ch03-metadata.typ`, `ch04-the-contract.typ`, `ch05-the-execution.typ`.

**Dependencies.** Phase 2 merged; organisms `charter` and `status-report` frozen for the phase duration.

**Exit criteria.**
- `_fixture.typ` has every namespace populated with realistic (not placeholder) Aurora data.
- Ch 4 compiles and includes a full `#charter(project)` render of the fixture.
- Ch 5 compiles and includes a full `#status-report(project)` render of the fixture.
- A reader can diff the rendered charter against the rendered status report and see that they share data but differ in presentation.

**Risk flags.**
- [HIGH RISK] Fixture design. Getting Aurora right is the book's spine. Underspecified → weak showcases; over-specified → chapters drown in detail. Budget one working session specifically for fixture design before writing Ch 3.
- [REVISIT] If `status-report` or `charter` requires fields the fixture lacks, extend the fixture — not the organism.

### Phase 4 — Closure, Reference, & Ship *(2–3 days)*
**Goal.** The book is complete; the PDF is committed.

**Components to build.** `ch06-closure.typ`, `ch07-reference.typ`, compiled `docs/manual.pdf`.

**Dependencies.** Phase 3 merged.

**Exit criteria.**
- Ch 7 includes the full schema table and crosswalk matrix.
- Ch 6 documents closure namespace honestly with no fake organism.
- `docs/manual.pdf` is committed and linked from the README.
- README's "Manual" link opens a PDF that reads front-to-back cleanly.

**Risk flags.**
- [LOW] Ch 7's schema table will be tedious but mechanical.

### *(Deferred)* Phase 5 — Extensibility chapter
Add a chapter "Creating Your Own Organism" once a second contributor materializes. Deferred because it requires code-adjacent content the PM audience doesn't need and the internal API isn't yet stabilized.

---

## 7. Implementation Management

### Sequencing
Phases are strictly linear. Within a phase, chapters can be drafted in parallel but must merge in TOC order so each reviewer reads in book order.

**Dependency graph (plain text):**
```
typst.toml(exclude) ─┐
                     ├─► README.md ─┐
docs/manual.typ(scaffold) ─────────┘
                     │
                     ▼
              ch01, ch02 ───► _fixture.typ ───► ch03, ch04, ch05 ───► ch06, ch07 ───► manual.pdf
```

### Ownership suggestions
- README, typst.toml, manual.typ scaffold → **maintainer / author role**.
- Chapters 1, 2 → **author role** (pedagogy-heavy; strong editorial judgment matters).
- `_fixture.typ` + Chapters 4, 5 → **author role with PM reviewer** (technical-accuracy-heavy; domain expertise matters).
- Chapter 7 reference → **author role with automation assist** — the schema table can be partially generated from `src/contract/namespaces/*.typ` via a one-off script if the namespace files grow inline docstrings.

### Critical path
`_fixture.typ` → Ch 4 → Ch 5. Any delay in fixture finalization cascades into both capital chapters and therefore into the ship date.

### Integration points *(high-risk coordination)*
- **Fixture ↔ organisms.** The fixture must be validated against the current `charter` and `status-report` input contracts. [HIGH RISK] If either organism changes required fields mid-Phase-3, fixture and both showcases need updating.
- **README ↔ manual.** The quick-start in the README and the Ch 1 minimal example must stay aligned. Changes to one require updating the other in the same PR.

### Breaking changes flagged
- [HIGH RISK] Committing `manual.pdf` as a binary is a one-way door for git history size. If later switching to CI-built releases, the binary stays in history. Accept the trade-off knowingly.
- [REVISIT] `typst.toml` exclude rules — wrong patterns could accidentally publish docs to the Universe or exclude needed source files. Verify with a dry-run bundle before the first release tag.

---

## 8. Validation & Testing Strategy

| Layer | Test Type | What it verifies |
|---|---|---|
| Individual chapter | Compile test | Chapter compiles standalone to PDF |
| Full manual | Compile test | `docs/manual.typ` → `manual.pdf` produces expected page count ±10% |
| Fixture | Contract test | `_fixture.typ` feeds `#charter()` and `#status-report()` without warnings |
| README | Link check | All links resolve (GitHub rendered view + raw) |
| Package | Packaging test | Dry-run bundle excludes `docs/`, `examples/`, `*.pdf` |
| Architecture | Fitness function | Dependency rules and boundary enforcement |

### Architecture fitness functions *(enforced by `scripts/check-docs.sh`)*
1. No chapter file contains `#include` or `#import` of another chapter file.
2. Every chapter from Ch 2 onward imports `_fixture.typ` OR declares in a header comment that it intentionally does not need the fixture.
3. Every capital chapter (`ch04`, `ch05`) contains at least one organism invocation (`#charter` or `#status-report`).
4. `typst.toml` `exclude` list is non-empty and contains `docs/**`.

### Local dev validation
Before opening a PR for any chapter, the author runs:
1. `typst compile docs/chapters/chNN-*.typ /tmp/chNN.pdf` — chapter compiles alone.
2. `typst compile docs/manual.typ docs/manual.pdf` — full book compiles.
3. `scripts/check-docs.sh` — fitness functions pass.
4. Eyeball the full PDF's TOC and page count.

### Observability strategy *(production = "the published PDF")*
- **Version stamp on the cover:** `v{folio.version} · built {date}`. A reader can tell at a glance whether their PDF matches the package version installed.
- **Chapter footer:** chapter number + short title + page. Standard book practice; stated here as a contract.
- **Generation log** committed alongside the PDF? Not needed at this scale — revisit at Phase 5.

---

## 9. Open Questions & Risks

### Unknowns that could invalidate a decision
- **Typst Universe packaging spec.** `typst.toml` exclude key name and glob syntax must be verified against the current Typst packaging docs before Phase 1 is considered complete. If the key is `excludes` or the glob dialect differs, Phase 1 exit criteria adjust accordingly.
- **Organism input tolerance.** Do `charter` and `status-report` tolerate a project that contains namespaces they don't use (e.g., does `charter` break if `project.registers` is populated)? `examples/03-degraded.typ` suggests yes; confirm before committing to Phase 3.
- **Cover-page API.** The manual uses `src/shell/cover-page.typ`. Is this stable and publicly exported, or an internal? If internal, either export it or build a local cover in `manual.typ`.

### External dependencies carrying risk
- The `formal` palette (`src/theme/palettes/formal.typ`) is currently the only palette. The manual uses it by default; if a contributor adds a second palette mid-drafting, pin `formal` explicitly in `manual.typ`.

### To prototype/spike before committing
- **Fixture feasibility spike *(half-day, before Phase 3)*.** Write `_fixture.typ` with every namespace populated; pass it through both organisms; confirm clean renders with zero Typst warnings. If warnings appear, decide whether to fix the organism, the fixture, or the narrative.
- **Page-budget spike *(before Phase 2)*.** Compile a chapter stub of ~800 words of lorem + one rendered organism; measure page count. Calibrates expectations for the full manual length (target: 40–60 pages at v0.0.1).

### Risks accepted and documented
- **[HIGH RISK]** Shared-fixture coupling across chapters (§5, decision #2). Accepted — it is the book's central demonstration. Mitigated by centralizing fixture in one file.
- **[HIGH RISK]** Committed binary `manual.pdf` bloats git history (§5, decision #3). Accepted for single-maintainer simplicity at v0.0.1. Revisit at first CI introduction.
- **[LOW]** English-only manual may slow adoption by the Spanish-speaking PM community that Folio's runtime i18n was built to serve. Accepted for v0.0.1; localized manual is a post-v1.0 item.

---

## Quick Reference: Deliverables Checklist

**Task 1 — README:** one file (`README.md`), rewritten.

**Task 2 — Manual (under `docs/`):**
- `docs/manual.typ` (orchestrator, rewritten)
- `docs/manual.pdf` (compiled artifact, new)
- `docs/chapters/_fixture.typ` (new)
- `docs/chapters/ch01-getting-started.typ` (new)
- `docs/chapters/ch02-foundations.typ` (new)
- `docs/chapters/ch03-metadata.typ` (new)
- `docs/chapters/ch04-the-contract.typ` (new) — **★ charter showcase**
- `docs/chapters/ch05-the-execution.typ` (new) — **★ status-report showcase**
- `docs/chapters/ch06-closure.typ` (new)
- `docs/chapters/ch07-reference.typ` (new)
- `docs/assets/diagrams/` (new directory, populated as needed)

**Supporting:**
- `typst.toml` — add `exclude` entry.
- `scripts/check-docs.sh` — fitness function enforcement (optional but recommended at Phase 1).

**Total new/modified files:** 13 (+ assets directory + 1 optional script).

**Estimated total effort:** 13–18 working days across 4 phases, single author.