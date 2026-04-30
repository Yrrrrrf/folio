#import "@local/folio:0.0.1": project-doc, card, data-table, resolve
#import "@preview/gantty:0.5.1" as gantty
#import "project.typ": project-data

// ─── Visual Gantt Rendering Function ───────────────────────────────────────
#let visual-gantt-section(data-path) = context {
  heading(level: 2)[Visual Schedule (Gantt)]
  
  import gantty: (
    dependencies.default-dependencies-drawer, dividers.default-dividers-drawer, field.default-field-drawer, gantt,
    milestones.default-milestones-drawer, sidebar.default-sidebar-drawer, task.default-tasks-drawer,
  )
  import gantty.header: (
    default-headers-drawer,
    default-month-header,
    default-day-header,
  )

  let azul-oscuro = rgb("#0d47a1")
  let azul-medio = rgb("#1e88e5")
  let azul-claro = rgb("#90caf9")
  let gris-linea = rgb("#e0e0e0")
  let naranja = rgb("#ef6c00")

  let drawer = (
    field: default-field-drawer,
    dependencies: default-dependencies-drawer,
    sidebar: default-sidebar-drawer.with(
      padding: 15pt,
      spacing: 12pt,
      formatters: (
        fase => align(right, text(weight: "bold", size: 10pt, smallcaps(fase.name))),
        act => align(right, text(size: 9pt, act.name)),
      ),
      dividers: (
        (stroke: (paint: azul-medio, thickness: 1.5pt)),
        (stroke: (paint: gris-linea, thickness: 0.5pt)),
      ),
      stroke: (paint: azul-oscuro, thickness: 1pt),
    ),
    headers: default-headers-drawer.with(headers: (
      default-month-header(
        table-style: (stroke: (paint: azul-oscuro, thickness: 1.5pt)),
      ),
      default-day-header(
        table-style: (stroke: (paint: azul-claro, thickness: 0.5pt)),
        gridlines-style: (stroke: (paint: gris-linea, thickness: 0.2pt, dash: "dotted")),
      ),
    )),
    tasks: default-tasks-drawer.with(
      styles: (
        (uncompleted: (style: (fill: azul-medio, stroke: azul-oscuro), width: 16pt)),
        (uncompleted: (style: (fill: azul-claro, stroke: azul-medio), width: 10pt)),
      ),
    ),
    dividers: default-dividers-drawer.with(styles: (
      (stroke: (paint: azul-medio, thickness: 1pt)),
      (stroke: (paint: gris-linea, thickness: 0.4pt)),
    )),
    milestones: default-milestones-drawer.with(
      style: (stroke: (paint: naranja, thickness: 2pt)),
    ),
  )

  let gantt-data = (
    start: project-data.project.start_date,
    end: project-data.project.gantt_render_end,
    tasks: project-data.baselines.schedule.phases,
    milestones: project-data.baselines.schedule.milestones,
  )

  block(width: 100%, height: auto, breakable: true)[
    #gantt(gantt-data, drawer: drawer)
  ]
}

// ─── Custom Migration Section ──────────────────────────────────────────────
#let migration-concerns-section(data-path) = {
  heading(level: 2)[Migration Analysis]
  
  card(title: "Legacy Feature Restoration")[
    The Visual Gantt Chart has been restored as a custom hybrid section using the `gantty` package, 
    maintaining the original nested `phases` data structure alongside Folio's flat task list.
  ]
  
  card(title: "Extended Risk Register")[
    To demonstrate Folio's scalability, the risk register has been expanded to 10 items covering technical, environmental, and administrative factors specific to fiber optic infrastructure.
  ]
}

// ─── Roadmap Section ───────────────────────────────────────────────────────
#let roadmap-section(data-path) = {
  heading(level: 2)[Future Roadmap: Folio Enhancements]
  
  card(title: "Top 3 Architectural Targets")[
    #data-table(
      columns: (auto, 1fr),
      headers: ("Feature", "Description"),
      rows: (
        "Budget-Plus", "Support for qty/unit/unit_cost with auto-calculations.",
        "Integrated Gantt", "Native visual timeline primitive inside Folio core.",
        "Theme Intents", "Automatic mapping of project statuses to brand colors.",
      )
    )
  ]
  
  card(title: "Additional Goals")[
    - *Institutional Templates:* Academic (UAEMéx) and Corporate layout presets.
    - *Variance Analysis:* Planned vs Actual spend and schedule tracking.
    - *Interactive Audits:* Context-aware reasoning for missing PMBOK fields.
  ]
}

// ─── Folio Orchestration ───────────────────────────────────────────────────
#show: project-doc(
  data: project-data,
  config: (
    audit: true,
    toc: true,
    extra-sections: (
      (
        id: "migration-concerns",
        phase: "planning",
        data-path: "project",
        render: migration-concerns-section,
        after: "budget"
      ),
      (
        id: "visual-gantt",
        phase: "planning",
        data-path: "baselines.schedule.phases",
        render: visual-gantt-section,
        after: "gantt"
      ),
      (
        id: "folio-roadmap",
        phase: "closure",
        data-path: "project",
        render: roadmap-section,
        after: "sign_off"
      ),
    )
  ),
)
