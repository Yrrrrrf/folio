#import "../../util/mod.typ": get-state, list, nonempty, t
#import "../../util/cross-ref.typ": register, resolve
#import "../../primitives/mod.typ": ftable, badge, h

#let issues-log(overrides: (:)) = context {
  let s = get-state()
  if not nonempty(s.data, "registers.issue_log") { return [] }
  
  h(1, t("section.issues.title"))
  
  let issues = list(s.data, "registers.issue_log")
  
  // Sort Open first
  issues = issues.sorted(key: i => if i.at("status", default: "open") == "closed" { 1 } else { 0 })
  
  let rows = ()
  for i in issues {
    let id = i.at("id", default: "")
    let desc = i.at("desc", default: "")
    let stat = i.at("status", default: "open")
    let prior = i.at("priority", default: "low")
    let owner = i.at("owner", default: "")
    
    if id != "" { register("issue", id, desc) }
    
    let st-bdg = badge(t("status." + stat), tone: if stat == "open" { "info" } else { "neutral" })
    let pr-bdg = badge(t("priority." + prior), tone: if prior == "high" { "danger" } else if prior == "medium" { "warn" } else { "neutral" })
    
    rows.push((
      id,
      desc,
      [#st-bdg #box(width: 0.5em) #pr-bdg],
      owner
    ))
  }
  
  ftable(
    (auto, 1fr, auto, auto),
    header: ("ID", "Descripción", "Estado / Prioridad", "Dueño"),
    rows: rows
  )
}
