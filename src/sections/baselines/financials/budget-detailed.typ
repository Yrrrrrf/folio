#import "../../../util/mod.typ": get-state, list, nonempty, t, financials
#import "../../../primitives/mod.typ": ftable, h

#let fmt-money(amount) = {
  "$" + str(amount) + " MXN"
}

#let budget-detailed(overrides: (:)) = context {
  let s = get-state()
  if not nonempty(s.data, "baselines.financials.line_items") { return [] }
  
  h(1, t("section.budget_detailed.title"))
  
  let line-items = list(s.data, "baselines.financials.line_items")
  let subtotal = financials.line-items-subtotal(line-items)
  let extras-raw = list(s.data, "baselines.financials.extras")
  let resolved-extras = financials.resolve-extras(extras-raw, subtotal)
  let contingency = s.data.baselines.financials.contingency_reserve
  let grand-total = financials.grand-total(subtotal, resolved-extras, contingency)
  
  let categorized = financials.categorize(line-items)
  
  // 1. Cost Distribution (Bar Chart Simulado)
  h(2, "Distribución de Costos")
  
  let chart-data = categorized.map(cat => (name: cat.category, cost: cat.subtotal))
  if resolved-extras.len() > 0 {
    let extras-sum = resolved-extras.map(e => e.amount).sum()
    chart-data.push((name: "Servicios & Extras", cost: extras-sum))
  }
  if contingency > 0 {
    chart-data.push((name: "Contingencia", cost: contingency))
  }
  
  let max-cost = if chart-data.len() > 0 { calc.max(..chart-data.map(c => c.cost)) } else { 1 }
  
  v(1em)
  for cat in chart-data {
    let bar-length = (cat.cost / max-cost) * 80%
    grid(
      columns: (120pt, 1fr, auto),
      gutter: 10pt,
      align(right + horizon, text(size: 0.8em, cat.name)),
      box(height: 12pt, width: 100%, {
        rect(height: 100%, width: bar-length, fill: rgb("#1e88e5").lighten(30%), radius: 2pt)
      }),
      text(size: 0.8em, weight: "bold", fmt-money(cat.cost)),
    )
    v(0.4em)
  }
  v(1em)

  // 2. Detailed Category Tables
  for cat in categorized {
    h(2, cat.category)
    let rows = cat.items.map(it => (
      it.at("id", default: "-"),
      it.at("description", default: ""),
      str(it.at("qty", default: 0)),
      it.at("unit", default: ""),
      fmt-money(it.at("unit_cost", default: 0)),
      [#text(weight: "bold", fmt-money(it.at("qty", default: 0) * it.at("unit_cost", default: 0)))]
    ))
    
    ftable(
      (auto, 1fr, auto, auto, auto, auto),
      header: ("ID", "Descripción", "Cant.", "Unidad", "Unitario", "Total"),
      rows: rows,
      totals: (table.cell(colspan: 5, align(right, text(weight: "bold", "Subtotal " + cat.category))), [#text(weight: "bold", fill: rgb("#1e88e5"), fmt-money(cat.subtotal))])
    )
  }
  
  // 3. Extras Table
  if resolved-extras.len() > 0 {
    h(2, "Servicios & Costos Adicionales")
    let rows = resolved-extras.map(ex => (
      ex.name,
      fmt-money(ex.amount)
    ))
    ftable(
      (1fr, auto),
      header: ("Concepto", "Monto"),
      rows: rows
    )
  }
  
  // 4. Grand Total Panel
  v(2em)
  align(right, block(
    width: 200pt,
    fill: rgb("#f5f5f5"),
    inset: 12pt,
    radius: 4pt,
    stack(spacing: 8pt,
      grid(columns: (1fr, auto), gutter: 8pt,
        text(size: 0.9em, "Subtotal:"), text(size: 0.9em, fmt-money(subtotal)),
        ..resolved-extras.map(ex => (
          text(size: 0.9em, ex.name + ":"), text(size: 0.9em, fmt-money(ex.amount))
        )).flatten(),
        ..(if contingency > 0 {
          (text(size: 0.9em, "Contingencia:"), text(size: 0.9em, fmt-money(contingency)))
        } else { () }),
        line(length: 100%, stroke: 0.5pt + rgb("#e0e0e0")), [],
        text(size: 1.1em, weight: "bold", "TOTAL:"),
        text(size: 1.1em, weight: "black", fill: rgb("#0d47a1"), fmt-money(grand-total))
      )
    )
  ))
}
