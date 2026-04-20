#import "../../util/mod.typ": get-state, list, nonempty, t
#import "../../util/cross-ref.typ": register, resolve
#import "../../primitives/mod.typ": ftable, badge, h

#let severity(prob, imp) = {
  // Simple ordinal: High=3, Medium=2, Low=1
  let p = if prob == "high" { 3 } else if prob == "medium" { 2 } else { 1 }
  let i = if imp == "high" { 3 } else if imp == "medium" { 2 } else { 1 }
  p * i
}

#let risk-tone(level) = {
  if level == "high" { "red" } else if level == "medium" { "amber" } else { "green" }
}

#let risks(overrides: (top: none)) = context {
  let s = get-state()
  if not nonempty(s.data, "registers.risk_register") { return [] }
  
  h(1, t("section.risks.title"))
  
  let rks = list(s.data, "registers.risk_register")
  
  // Sort by calculated severity desc
  rks = rks.sorted(key: r => -severity(r.at("probability", default: "low"), r.at("impact", default: "low")))
  
  let top = overrides.at("top", default: none)
  if top != none and rks.len() > top {
    rks = rks.slice(0, top)
  }
  
  let rows = ()
  for r in rks {
    let id = r.at("id", default: "")
    let desc = r.at("desc", default: "")
    let prob = r.at("probability", default: "low")
    let imp = r.at("impact", default: "low")
    let wbs = r.at("affects_wbs", default: "")
    let mit = r.at("mitigation", default: "")
    
    if id != "" {
      register("risk", id, desc)
    }
    
    let prob-badge = badge(t("probability." + prob), tone: risk-tone(prob))
    let imp-badge = badge(t("impact." + imp), tone: risk-tone(imp))
    
    let mitig-col = if wbs != "" {
      [#mit \ #text(size: 0.85em)[Afecta: #resolve("wbs", wbs)]]
    } else {
      [#mit]
    }
    
    rows.push((
      id,
      desc,
      [#prob-badge #box(width: 0.5em) #imp-badge],
      mitig-col
    ))
  }
  
  ftable(
    (auto, 1fr, auto, 1fr),
    header: ("ID", "Riesgo", "P × I", "Mitigación"),
    rows: rows
  )
}
