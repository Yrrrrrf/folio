#import "../theme/mod.typ": presets
#import "../util/state.typ": get-state
#import "../i18n/mod.typ": t

#let ftable(columns, header: (), rows: (), totals: none, caption: none) = context {
  let pr = presets.at(get-state().theme-preset, default: presets.formal)
  
  let header-row = header.map(h => [
    #block(inset: 0.5em, text(fill: pr.palette.text.inverse, weight: "bold", h))
  ])
  
  let content-rows = ()
  let i = 0
  for row in rows {
    let fill = if calc.odd(i) { pr.palette.surface.card } else { pr.palette.surface.page }
    let formatted-row = row.map(cell => [
      #block(inset: 0.5em, text(fill: pr.palette.text.primary, cell))
    ])
    // Instead of using row fills directly in table, we use `table` fill arg or wrap cells.
    // Typst table allows fill: (col, row) => color. We'll use the table setup.
    content-rows.push(row)
    i += 1
  }
  
  if totals != none {
    content-rows.push(totals)
  }
  
  let t-fill = (col, row) => {
    if row == 0 { return pr.palette.brand.primary }
    if totals != none and row == content-rows.len() { return pr.palette.surface.overlay }
    if calc.odd(row) { pr.palette.surface.card } else { pr.palette.surface.page }
  }
  
  let t-stroke = (col, row) => {
    (bottom: 0.5pt + pr.palette.border.default)
  }
  
  let table-content = table(
    columns: columns,
    fill: t-fill,
    stroke: t-stroke,
    align: horizon,
    ..header-row,
    ..content-rows.flatten().map(cell => block(inset: 0.5em, text(fill: pr.palette.text.primary, cell)))
  )
  
  figure(
    kind: "folio-table",
    supplement: t("figure.table"),
    caption: caption,
    table-content
  )
}
