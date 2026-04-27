#import "../core/guard.typ": section-guard
#import "../primitives/card.typ": card
#import "../primitives/data_table.typ": data-table
#import "../utils/formatters.typ": _date

#let lessons_learned() = section-guard("Lessons Learned", "closure.lessons_learned", lessons => {
  data-table(
    columns: (auto, 1fr, 1fr),
    headers: ("Category", "What went wrong", "Recommendation"),
    rows: lessons.map(l => (
      l.at("category", default: "-"),
      l.at("issue", default: "-"),
      l.at("recommendation", default: "-")
    )).flatten()
  )
})

#let sign_off() = section-guard("Formal Sign-Off", "closure.sign_off", stakeholders => {
  data-table(
    columns: (1fr, 1fr, 1fr),
    headers: ("Stakeholder", "Role", "Date/Signature"),
    rows: stakeholders.map(s => (
      s.at("name", default: "-"),
      s.at("role", default: "-"),
      "___________________"
    )).flatten()
  )
})
