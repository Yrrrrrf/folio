# folio — Manifest

> **folio is a Typst package that turns a project's data into a publication-grade project management document. You write the data once. folio writes the document.**

This is the *why* document. It exists to anchor design decisions before they're made and to keep them honest after. The technical spec lives separately. If a future change conflicts with anything written here, that change is wrong by default — the principle has to be retired explicitly first.

---

## The problem

Project management documents — PMBOK plans, RFP responses, thesis project briefs, MVP plans, construction proposals — share 90% of their structure: cover, objectives, scope, schedule, budget, team, risks, status, lessons, sign-off. And yet every one of them is rebuilt from scratch: copy a template, retype the headings, fight the table widths, color-pick the brand, forget half the sections, ship something inconsistent.

The cost isn't the typing. It's the loss of a single source of truth. The budget appears in three places with three different totals. The team list goes stale on page 12 but not on page 4. The project ID gets a typo on the cover. None of these are interesting problems — they're the rate-limit on doing real project management.

folio's bet: if your project's *data* is a single dictionary, the *document* should fall out automatically — branded, ordered to international standards, complete with diagnostic placeholders for what you haven't filled in yet.

---

## Principles

### 1. The data is the document
Everything renderable lives in one nested dict. Sections read from it. Audit reads from it. Cross-references resolve through it. Section functions don't take parameters — they query the schema. Your `data.typ` *is* the project; everything else is presentation.

### 2. Zero-crash, gracefully missing
A folio document compiles even if the data is incomplete. Missing fields render as visible `_missing("path.to.field")` placeholders that mark what's absent without breaking the build. You can ship a stub on day one and watch placeholders disappear as the project fills in.

### 3. Single entry point
The consumer file is five lines. `#import`, `#let data`, `#show: project-doc(data, config, brand)`. Custom appended content is fine, but the document doesn't require it. If a user has to learn folio's internals to make their project render, folio failed.

### 4. Branding is an overlay, not a fork
A brand is a dictionary that overrides design tokens — color, typography, spacing, density. Anything not overridden falls back to the default theme. There is no "folio fork for company X" — there is a brand dict for company X.

### 5. The pipeline is data, not code
The 15 PMBOK-aligned sections are a default pipeline, not a closed set. Users opt out per-section, and **inject custom sections at named insertion points**. Adding, removing, or reordering sections is a data edit, not a patch.

### 6. The schema is the contract
The canonical shape of `data` is documented in one place and consumed by three: the section pipeline, the audit registry, and the schema reference itself. Drift between these three is a bug. There is exactly one supported shape — folio does not adapt, normalize, or guess. Data that doesn't match the schema must be reshaped by the consumer before it reaches `project-doc`. Single source of truth means single shape.

### 7. Audits diagnose, they never gatekeep
An optional pre-flight dashboard lists every PMBOK-significant field and its status (Present / Empty / Missing), grouped by severity, plus orphan cross-references. It tells you what's incomplete; it never refuses to compile. Templates register `extra-checks` for their own field requirements.

### 8. Formatters are pluggable
Currency, dates, numbers, and similar locale-shaped values vary by project. folio ships an English/USD-style default and accepts user-supplied `format-money` / `format-date` overrides through config. Locale gymnastics live in the consumer's project, not inside folio.

### 9. Composition over configuration
A project that's too big for one file lives in many files — `data/cover.typ`, `data/budget.typ`, `data/risks.typ` — merged into the single dict before `project-doc` consumes it. folio doesn't care whether the dict was authored as one literal or assembled from twenty. The schema is the only thing it sees.

### 10. Public API is small and stable; internals are not
The public surface is exactly: `project-doc`, the section functions, the UI primitives (`card`, `data-table`, `badge`, `metric`, `progress-bar`), and a handful of utilities (`folio-init`, `section-guard`, the formatters). Names with leading underscores (`_resolve`, `_missing`, `_money`, `_date`) are internal — using them in consumer code is unsupported and may break across patch releases.

---

## The contract folio offers

- **Compiles.** Any data dict, even `(:)`, produces a PDF.
- **Branded.** Any subset of design tokens can be overridden via the `brand` argument.
- **Sectioned.** 15 PMBOK-aligned sections render in standard order; custom sections insert at named positions.
- **Auditable.** An opt-in dashboard shows what's present, empty, missing, and which cross-references are orphaned.
- **TOC-aware.** A table of contents can be generated automatically from rendered sections.
- **Decomposable.** A project can be one `data.typ` or a `data/` directory of section files merged into one dict — folio is indifferent.
- **API-stable.** The public surface (above) follows semantic versioning starting at 0.1.0; internal helpers (leading `_`) carry no stability guarantee.

---

## What folio is not

- **Not a typesetting framework.** Typst is. folio sits on top.
- **Not localized.** All identifiers, headings, vocabulary, and code comments are English. Content (project text) is whatever language the user writes.
- **Not interactive.** No PDF forms, no JavaScript, no live updates.
- **Not opinionated about methodology.** It targets the common ground of PMBOK, ISO 21500, and PRINCE2.
- **Not a thesis tool, RFP tool, or proposal tool specifically.** It's a project-shape tool. If your output looks like a project document with sections, folio fits.
- **Not a presentation tool.** It produces formal documents, not slide decks.

---

## Standards stance

PMBOK 7, ISO 21500, and PRINCE2 disagree on vocabulary and emphasis but agree on the underlying skeleton: every project has initiation (why), planning (what / when / how much / who), execution (status / risks / issues / changes), and closure (lessons / sign-off). folio targets this common skeleton, names it after PMBOK because PMBOK names are the most searched, and exposes the schema flexibly enough that an ISO-vocabulary or PRINCE2-vocabulary template can map onto it via `get-title` overrides and `extra-checks` registration — without forking the package.

---

## Testability stance

folio's correctness is empirical, not unit-tested in the traditional sense. The verification loop is:

1. **Compile** — every fixture in `tests/fixtures/` must compile cleanly. A failed compile is a regression.
2. **Inspect** — a human (or a model with vision) reviews the rendered PDF for a fixture against expected behavior.
3. **Snapshot** — once accepted, a snapshot is captured. Future PRs that change the snapshot must be justified explicitly.

Compile success is the floor. It is *necessary* but not *sufficient*. A document that compiles and looks wrong is still wrong; a document that doesn't compile is broken.

---

## Success

A friend asks you to format their thesis project, their startup MVP plan, or their construction RFP. You don't open Typst. You don't copy a template. You hand them this:

```typst
#import "@local/folio:0.0.1": project-doc
#import "data.typ": project

#show: project-doc(
  project,
  config: (audit: true, toc: true),
  brand: (palette: (primary: rgb("#003e7e"))),
)
```

…and that's the entire consumer file. Whatever's in `project` renders correctly. Whatever's missing shows as a red placeholder pointing at the right path. They don't need to know what PMBOK is — the structure is right because folio is right.

**When that works for any project, not just project 01, folio v0.0.1 ships.**
---

## Schema Decisions

### Decision: Requirements and Budget are separate arrays

folio uses two distinct arrays:
- `baselines.requirements` — **what** must be delivered (functional/quality specifications)
- `baselines.financials.budget.line_items` — **how much** financial allocation per work item

These serve different stakeholder audiences, render in different sections, and update at different cadences. A regulatory requirement has no cost; a budget line item may cover multiple requirements or no requirements at all.

**The `req_id` field on budget line items is the traceability link.** It declares "this budget line funds requirement X" — it is not a derivation source. The budget figure is authoritative for financial reporting; the requirement is authoritative for scope acceptance.

**SSOT principle applies within each domain.** Each requirement is written once in `baselines.requirements`. Each budget item is written once in `baselines.financials.budget.line_items`. The `req_id` link is the single place where the two domains intersect.

**Cost drift detection:** `find-orphans()` checks that every `req_id` on a budget item resolves to a real requirement. A future `audit-cost-drift()` function (v0.1.0) will additionally warn when a budget item's unit cost differs from the linked requirement's `unit_cost` field — surfacing accidental inconsistency without making it a hard error.

**Revisit condition:** If a project type emerges where every requirement maps 1:1 to a budget line item and users repeatedly write the same item twice, an optional `use-requirements-as-budget: true` config flag (not a schema change) could derive budget automatically. This is deferred to v0.1.0.
