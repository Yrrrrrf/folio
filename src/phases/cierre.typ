#import "../core/guard.typ"
#import "../theme/ui.typ": card, data-table
#import "../utils/formatters.typ": _date
#import "../core/state.typ": folio-state
#import "../core/resolve.typ": _resolve, get-title

#let lessons_learned() = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  heading(level: 2)[#get-title(data, "closure.lessons_learned", "Lessons Learned")]
  
  let lessons = _resolve(data, "closure.lessons_learned")
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
    lessons
  }
}

#let sign_off() = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  heading(level: 2)[#get-title(data, "closure.sign_off", "Formal Sign-Off")]
  
  let stakeholders = _resolve(data, "closure.sign_off")
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
    stakeholders
  }
}
