#import "../../../util/mod.typ": get-state, list, nonempty, t
#import "../../../util/cross-ref.typ": register
#import "../../../primitives/mod.typ": ftable, timeline-bar, h
#import "../../../theme/mod.typ": presets

#let milestones(overrides: (:)) = context {
  let s = get-state()
  if not nonempty(s.data, "baselines.schedule.milestones") { return [] }
  
  h(1, t("section.milestones.title"))
  
  let ms = list(s.data, "baselines.schedule.milestones")
  let start-d = s.data.baselines.schedule.start_date
  let end-d = s.data.baselines.schedule.end_date
  
  let render-timeline = start-d != "" and end-d != ""
  
  let rows = ()
  for m in ms {
    let id = m.at("id", default: "")
    let name = m.at("name", default: "Hito")
    let d = m.at("date", default: "")
    let typ = m.at("type", default: "")
    
    // Register
    if id != "" {
      register("milestone", id, name)
    }
    
    // Fallback if no timeline
    rows.push((name, d, typ))
  }
  
  let pr = presets.at(get-state().theme-preset, default: presets.formal)
  if render-timeline {
    box(width: 100%, stroke: (bottom: 0.5pt + pr.palette.border.default), inset: (bottom: 1em), [
      #for m in ms {
        let d = m.at("date", default: "")
        if d != "" {
          timeline-bar(d, d, start-d, end-d, label: m.at("name", default: ""))
          v(0.2em)
        }
      }
    ])
    v(1em)
  }
  
  ftable(
    (auto, auto, 1fr),
    header: ("Hito", "Fecha", "Tipo"),
    rows: rows
  )
}
