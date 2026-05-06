#import "../theme/resolver.typ": resolve-token, resolve-spacing
#import "../core/state.typ": folio-state

#let data-table(
  columns: auto, 
  headers: (), 
  rows: (),
  border-color: none,
  bg-header: none,
  pad: none,
  header-size: none,
  alternating-rows: true
) = context {
  let st = folio-state.get()
  
  let border-color = if border-color != none { border-color } else { resolve-token(st, "palette.surface.border") }
  let bg-header = if bg-header != none { bg-header } else { resolve-token(st, "palette.surface.card") }
  let bg-alt = resolve-token(st, "palette.surface.alt")
  let pad = if pad != none { pad } else { resolve-token(st, "geometry.table.cell-padding") }
  let header-size = if header-size != none { header-size } else { resolve-token(st, "typography.size.sm") }
  let stroke-width = resolve-token(st, "geometry.stroke-width.thin")
  let rad = resolve-token(st, "geometry.radius.table")

  // For rounded corners on tables, we wrap in a block/rect
  block(
    radius: rad,
    clip: true,
    stroke: stroke-width + border-color,
    table(
      columns: columns,
      stroke: stroke-width + border-color,
      fill: (col, row) => {
        if row == 0 { bg-header }
        else if alternating-rows and calc.odd(row) { bg-alt }
        else { none }
      },
      inset: pad,
      ..headers.map(h => text(weight: "bold", size: header-size)[#h]),
      ..rows.flatten()
    )
  )
}
