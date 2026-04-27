#import "@preview/gantty:0.5.1" as gantty
#import "../../../util/mod.typ": get-state, nonempty, t
#import "../../../primitives/mod.typ": h
#import "../../../theme/mod.typ": presets

#let gantt-section(overrides: (:)) = context {
  let s = get-state()
  if not nonempty(s.data, "baselines.schedule.phases") { return [] }
  
  let pr = presets.at(s.theme-preset, default: presets.formal)
  
  let sched = s.data.baselines.schedule
  let start-date = sched.at("start_date")
  let end-date = sched.at("gantt_render_end", default: sched.at("end_date"))
  let phases = sched.at("phases")
  let milestones = sched.at("milestones", default: ())
  
  h(1, t("section.gantt.title"))

  import gantty: (
    dependencies.default-dependencies-drawer, dividers.default-dividers-drawer, field.default-field-drawer, gantt,
    milestones.default-milestones-drawer, sidebar.default-sidebar-drawer, task.default-tasks-drawer,
  )
  import gantty.header: (
    default-headers-drawer,
    default-month-header,
    default-day-header,
  )

  let color-primary = pr.palette.brand.primary
  let color-accent = pr.palette.brand.accent
  let color-border = pr.palette.border.default
  let color-text-muted = pr.palette.text.muted

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
        (stroke: (paint: color-primary, thickness: 1.5pt)),
        (stroke: (paint: color-border, thickness: 0.5pt)),
      ),
      stroke: (paint: color-primary, thickness: 1pt),
    ),
    headers: default-headers-drawer.with(headers: (
      default-month-header(
        table-style: (stroke: (paint: color-primary, thickness: 1.5pt)),
      ),
      default-day-header(
        table-style: (stroke: (paint: color-accent.lighten(50%), thickness: 0.5pt)),
        gridlines-style: (stroke: (paint: color-border, thickness: 0.2pt, dash: "dotted")),
      ),
    )),
    tasks: default-tasks-drawer.with(
      styles: (
        (uncompleted: (style: (fill: color-primary, stroke: color-primary.darken(20%)), width: 16pt)),
        (uncompleted: (style: (fill: color-accent.lighten(40%), stroke: color-accent), width: 10pt)),
      ),
    ),
    dividers: default-dividers-drawer.with(styles: (
      (stroke: (paint: color-primary, thickness: 1pt)),
      (stroke: (paint: color-border, thickness: 0.4pt)),
    )),
    milestones: default-milestones-drawer.with(
      style: (stroke: (paint: pr.palette.status.amber, thickness: 2pt)),
    ),
  )

  let gantt-data = (
    start: start-date,
    end: end-date,
    tasks: phases,
    milestones: milestones,
  )

  pagebreak()
  set page(width: 35cm, height: auto, margin: 1cm)
  
  gantt(gantt-data, drawer: drawer)
  
  pagebreak()
}
