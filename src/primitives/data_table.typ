#import "../core/state.typ": folio-state
#import "../theme/resolver.typ": resolve-token, resolve-spacing

#let data-table(columns: auto, headers: (), rows: ()) = context {
  let st = folio-state.get()
  
  let border-color = resolve-token(st, "palette.surface.border")
  let bg-header = resolve-token(st, "palette.surface.card")
  let pad = resolve-spacing(st, multiplier: 0.75)
  
  table(
    columns: columns,
    stroke: 0.5pt + border-color,
    fill: (col, row) => if row == 0 { bg-header } else { none },
    inset: pad,
    ..headers.map(h => text(weight: "bold", size: resolve-token(st, "typography.size.sm"))[#h]),
    ..rows
  )
}
