#import "../core/resolve.typ": resolve, get-title
#import "../core/state.typ": folio-state
#import "../theme/ui.typ": card, data-table

#let lessons-learned(data-path) = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  heading(level: 2)[#get-title(data, data-path, "Lessons Learned")]
  
  let lessons = resolve(data, data-path)
  if type(lessons) == array {
    data-table(
      columns: (auto, 1fr, 1fr),
      headers: ("Category", "What went wrong", "Recommendation"),
      rows: lessons.map(l => (
        l.at("category", default: "-"),
        l.at("issue", default: "-"),
        l.at("recommendation", default: "-")
      )).flatten()
    )
  } else {
    [#lessons]
  }
}

#let sign-off(data-path) = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  heading(level: 2)[#get-title(data, data-path, "Formal Sign-Off")]
  
  let stakeholders = resolve(data, data-path)
  if type(stakeholders) == array {
    data-table(
      columns: (1fr, 1fr, 1fr),
      headers: ("Stakeholder", "Role", "Date/Signature"),
      rows: stakeholders.map(s => (
        s.at("name", default: "-"),
        s.at("role", default: "-"),
        "___________________"
      )).flatten()
    )
  } else {
    [#stakeholders]
  }
}
