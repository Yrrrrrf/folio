#import "../core/guard.typ": section-guard
#import "../primitives/card.typ": card
#import "../primitives/data_table.typ": data-table
#import "../primitives/badge.typ": badge
#import "../core/state.typ": folio-state

#let cover() = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  
  let proj = data.at("project", default: (:))
  let name = proj.at("name", default: "[Project Name Missing]")
  let desc = proj.at("description", default: "[Project Description Missing]")
  
  align(center + horizon)[
    #text(size: 3em, weight: "bold")[#name]
    #v(1em)
    #text(size: 1.5em, style: "italic")[#desc]
  ]
  pagebreak()
}

#let pitch() = section-guard("Elevator Pitch", "initiation.pitch", pitch => {
  card[#pitch]
})

#let business_case() = section-guard("Business Case", "initiation.business_case", bc => {
  card[#bc]
})

#let objectives() = section-guard("Project Objectives", "initiation.objectives", obj-list => {
  data-table(
    columns: (auto, 1fr, auto),
    headers: ("ID", "Objective", "Priority"),
    rows: obj-list.map(o => (
      o.at("id", default: "-"),
      o.at("description", default: "-"),
      badge(o.at("priority", default: "neutral"), intent: if o.at("priority", default: "") == "high" { "danger" } else { "neutral" })
    )).flatten()
  )
})
