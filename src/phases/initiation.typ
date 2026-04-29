#import "../core/guard.typ"
#import "../theme/ui.typ": card, data-table, badge
#import "../core/state.typ": folio-state
#import "../core/resolve.typ": resolve, get-title

#let cover() = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  
  let name = resolve(data, "project.name")
  let desc = resolve(data, "project.description")
  
  align(center + horizon)[
    #text(size: 3em, weight: "bold")[#name]
    #v(1em)
    #text(size: 1.5em, style: "italic")[#desc]
  ]
  pagebreak()
}

#let pitch() = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  heading(level: 2)[#get-title(data, "initiation.pitch", "Elevator Pitch")]
  card[#resolve(data, "initiation.pitch")]
}

#let business-case() = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  heading(level: 2)[#get-title(data, "initiation.business_case", "Business Case")]
  card[#resolve(data, "initiation.business_case")]
}

#let objectives() = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  heading(level: 2)[#get-title(data, "initiation.objectives", "Project Objectives")]
  
  let obj-list = resolve(data, "initiation.objectives")
  if type(obj-list) == array {
    data-table(
      columns: (auto, 1fr, auto),
      headers: ("ID", "Objective", "Priority"),
      rows: obj-list.map(o => (
        o.at("id", default: "-"),
        o.at("description", default: "-"),
        badge(o.at("priority", default: "neutral"), intent: if o.at("priority", default: "") == "high" { "danger" } else { "neutral" })
      )).flatten()
    )
  } else {
    obj-list
  }
}
