#import "../../util/mod.typ": get-state, list, nonempty, t
#import "../../primitives/mod.typ": ftable, h

#let assumptions-log(overrides: (:)) = context {
  let s = get-state()
  if not nonempty(s.data, "registers.assumptions_log") { return [] }
  
  h(1, t("section.assumptions.title"))
  
  let assumptions = list(s.data, "registers.assumptions_log")
  let rows = assumptions.map(a => (
    a.at("id", default: ""),
    a.at("type", default: ""),
    a.at("desc", default: ""),
    a.at("owner", default: "")
  ))
  
  ftable(
    (auto, auto, 1fr, auto),
    header: ("ID", "Tipo", "Descripción", "Dueño"),
    rows: rows
  )
}
