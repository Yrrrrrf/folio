#import "../../util/mod.typ": get-state, t, present
#import "../../primitives/mod.typ": h, badge, card

#let status-report(overrides: (:)) = context {
  let s = get-state()
  let has-exec = present(s.data, "governance.status.executive_summary")
  let has-rag = present(s.data, "governance.status.rag_status")
  let has-domains = present(s.data, "governance.status.domain_rag")
  
  if not has-exec and not has-rag and not has-domains { return [] }
  
  h(1, t("section.status.title"))
  
  if has-rag {
    let stat = s.data.governance.status.rag_status
    let tone = if stat == "red" { "red" } else if stat == "amber" { "amber" } else { "green" }
    [#badge(t("rag." + stat), tone: tone)]
    v(1em)
  }
  
  if has-exec {
    s.data.governance.status.executive_summary
    v(1.5em)
  }
  
  if has-domains {
    let d = s.data.governance.status.domain_rag
    let cols = ()
    let cards = ()
    for (domain, stat) in d {
      cols.push(1fr)
      let tone = if stat == "red" { "red" } else if stat == "amber" { "amber" } else if stat == "green" { "green" } else { "neutral" }
      cards.push(card([
        #text(weight: "bold")[#domain] \
        #v(0.5em)
        #badge(t("rag." + stat), tone: tone)
      ]))
    }
    
    grid(
      columns: cols,
      gutter: 1.5em,
      ..cards
    )
  }
}
