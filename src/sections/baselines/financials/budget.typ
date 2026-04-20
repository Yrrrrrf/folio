#import "../../../util/mod.typ": get-state, list, nonempty, t, format
#import "../../../primitives/mod.typ": ftable, h

#let budget(overrides: (:)) = context {
  let s = get-state()
  if not nonempty(s.data, "baselines.financials.budget_items") { return [] }
  
  h(1, t("section.budget.title"))
  
  let items = list(s.data, "baselines.financials.budget_items")
  let cont = s.data.baselines.financials.contingency_reserve
  
  let rows = ()
  let sum = 0
  for item in items {
    let name = item.at("name", default: "")
    let cost = item.at("cost_minor", default: 0)
    sum += cost
    rows.push((name, format.currency(cost)))
  }
  
  if cont > 0 {
    rows.push(([ #text(style: "italic")[Reserva de Contingencia] ], format.currency(cont)))
    sum += cont
  }
  
  ftable(
    (1fr, auto),
    header: ("Concepto", "Monto"),
    rows: rows,
    totals: ([#text(weight:"bold", t("section.budget.total"))], [#text(weight:"bold", format.currency(sum))])
  )
}
