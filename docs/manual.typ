#set page(
  paper: "a4",
  margin: (x: 2.5cm, y: 3cm),
)
#set text(font: "New Computer Modern", size: 10pt)
#set heading(numbering: "1.")

#align(center)[
  #text(size: 24pt, weight: "bold")[Folio — Package Manual]

  #v(1em)
  #text(size: 14pt, style: "italic", fill: rgb("#616161"))[Universal Project Management Document Generator for Typst]

  #v(0.5em)
  #raw("#import \"@preview/folio:0.0.1\": *", block: false)
]

#v(2em)
#line(length: 100%, stroke: 0.5pt + luma(200))
#v(2em)

= Overview
Brief description of Folio's purpose: define your project once in a single `project` dictionary and generate a full PM document suite from it.

*Design principles:*
- Single Source of Truth (`dt.typ`)
- Zero boilerplate — import, call, compile
- All fields are optional; missing ones degrade gracefully
- Consistent branding across every document

#v(1em)
#line(length: 100%, stroke: 0.5pt + luma(200))

= Quick Start
Two-file setup:
+ `dt.typ` — your project data dictionary
+ `main.typ` — import folio, import project, call document functions

```typ
#import "@preview/folio:0.0.1": *
#import "dt.typ": project

#charter(project)
#pagebreak()
#gantt(project)
```

Then: `typst compile main.typ`

#v(1em)
#line(length: 100%, stroke: 0.5pt + luma(200))

= Available Documents

#table(
  columns: (3fr, 3fr, 5fr),
  align: left,
  stroke: 0.5pt + luma(200),
  fill: (col, row) => if row == 0 { luma(240) } else { none },
  [*Function*], [*Document*], [*Purpose*],
  [`charter(project)`], [Project Charter], [Identity, objectives, scope, team],
  [`feasibility(project)`], [Feasibility Study], [Technical/economic/operative analysis],
  [`executive-brief(project)`], [Executive Brief], [One-page sponsor summary],
  [`plan(project)`], [Project Plan], [Scope, quality, comms plan],
  [`requirements(project)`], [Requirements / BOM], [Categorised cost list],
  [`budget(project)`], [Budget], [Full cost breakdown + grand total],
  [`gantt(project)`], [Gantt Chart], [Auto-generated timeline],
  [`risks(project)`], [Risk Register], [Probability/impact matrix],
  [`stakeholders(project)`], [Stakeholder Map], [Influence & interest register],
  [`closure(project)`], [Project Closure], [Sign-off & acceptance],
)

#block(
  fill: rgb("#fff3cd"),
  stroke: rgb("#ffe69c"),
  inset: 1em,
  radius: 4pt,
  width: 100%,
)[
  *⚠️ Note:* `gantt` sets its own page size (`width: 35cm`). Always precede it with `#pagebreak()`.
]

#v(1em)
#line(length: 100%, stroke: 0.5pt + luma(200))

= Project Data Reference

== Identity
`name`, `version`, `status`, `description`, `start_date`, `end_date`, `gantt_render_end`

== People
- `owner` — string
- `team` — array of `(name, role, responsibilities)`
- `stakeholders` — array of `(name, organization, power, interest, channel, attitude)`

== Scope & Goals
- `objectives`, `benefits` — arrays of strings
- `scope` — dict with `included` and `excluded` arrays

== Feasibility
Dict with `technical`, `economic`, `operative` strings

== Resources
- `requirements` — array of `(id, description, unit, qty, unit_cost, category)`
- `tech_requirements` — array of strings (non-costed constraints)
- `budget_extras` — array of `(description, cost)`

== Risks
Array of `(id, description, probability, impact, mitigation)` \
Values: `"Alto"` / `"Medio"` / `"Bajo"` — auto-coloured badges

== Schedule
- `phases` — array of `(name, subtasks[])` where each subtask has `(name, start, end)`
- `milestones` — array of `(name, date, show-date)`

== Quality & Comms
- `quality_criteria`, `notes` — arrays of strings
- `communication_plan` — array of `(audience, frequency, channel, owner)`

== Closure
`acceptance_date`, `client_signature`, `completed_deliverables`

#v(1em)
#line(length: 100%, stroke: 0.5pt + luma(200))

= Full Schema (copy-paste template)

```typ
#let project = (
  name: "", version: "", status: "", description: "",
  start_date: "", end_date: "", gantt_render_end: "",
  owner: "",
  team: ((name: "", role: "", responsibilities: ""),),
  stakeholders: ((name: "", organization: "", power: "", interest: "", channel: "", attitude: ""),),
  objectives: (), benefits: (),
  scope: (included: (), excluded: ()),
  feasibility: (technical: "", economic: "", operative: ""),
  tech_requirements: (),
  requirements: ((id: "", description: "", unit: "", qty: 0, unit_cost: 0, category: ""),),
  budget_extras: ((description: "", cost: 0),),
  risks: ((id: "", description: "", probability: "", impact: "", mitigation: ""),),
  phases: ((name: "", subtasks: ((name: "", start: "", end: ""),)),),
  milestones: ((name: "", date: "", show-date: true),),
  quality_criteria: (), notes: (),
  communication_plan: ((audience: "", frequency: "", channel: "", owner: ""),),
  acceptance_date: "", client_signature: "",
  completed_deliverables: (),
)
```

#v(1em)
#line(length: 100%, stroke: 0.5pt + luma(200))

= Design System

*Colours:* `azul-oscuro` (\#0d47a1) · `azul-medio` (\#1e88e5) · `gris-texto` (\#616161) · `verde-exito` (\#43a047) · `rojo-error` (\#e53935) · `naranja-main` (\#fb8c00)

*Font:* New Computer Modern · `size-title` 24pt · `size-header` 14pt · `size-body` 10pt · `size-small` 8pt

*Components:* `section-title` · `status-chip` · `risk-badge` · `priority-badge` · `info-pair` · `team-card` · `signature-block` · `req-table` · `budget-summary` · `gantt-chart`

#v(1em)
#line(length: 100%, stroke: 0.5pt + luma(200))
