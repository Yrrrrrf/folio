#import "../../util/mod.typ": get-state, list, nonempty, t
#import "../../primitives/mod.typ": ftable, badge, h

#let change-log(overrides: (:)) = context {
  let s = get-state()
  if not nonempty(s.data, "registers.change_log") { return [] }
  
  h(1, t("section.changes.title"))
  
  let changes = list(s.data, "registers.change_log")
  
  let rows = ()
  for c in changes {
    let id = c.at("id", default: "")
    let desc = c.at("desc", default: "")
    let stat = c.at("status", default: "open")
    
    let bdg = badge(stat, tone: if stat == "Aprobado" { "success" } else if stat == "Rechazado" { "danger" } else { "info" })
    
    rows.push((id, desc, bdg))
  }
  
  ftable(
    (auto, 1fr, auto),
    header: ("ID", "Cambio", "Resolución"),
    rows: rows
  )
}
