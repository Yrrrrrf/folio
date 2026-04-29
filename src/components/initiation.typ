#import "../core/resolve.typ": resolve, get-title
#import "../core/state.typ": folio-state
#import "../theme/ui.typ": card, data-table, badge

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
}

#let pitch(data-path) = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  heading(level: 2)[#get-title(data, data-path, "Elevator Pitch")]
  let val = resolve(data, data-path)
  card[#val]
}

#let business-case(data-path) = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  heading(level: 2)[#get-title(data, data-path, "Business Case")]
  let val = resolve(data, data-path)
  card[#val]
}

#let objectives(data-path) = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  heading(level: 2)[#get-title(data, data-path, "Project Objectives")]
  
  let obj-list = resolve(data, data-path)
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
    [#obj-list]
  }
}
