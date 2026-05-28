/// Raw data-table primitive — takes explicit parameters only, no state access.
/// ui.typ resolves tokens and passes them here.
#let data-table(
  columns: auto,
  headers: (),
  rows: (),
  border-color: rgb("#e2e8f0"),
  bg-header: rgb("#f8fafc"),
  pad: 0.75em,
  header-size: 0.85em,
  alternating-rows: true,
  min-text-col: 80pt,
) = {
  // ── Guard: cell-count must be divisible by column-count ──
  let col-count = if type(columns) == int { columns } else if (
    type(columns) == array
  ) { columns.len() } else { 0 }
  let flat-rows = rows.flatten()
  let total-cells = headers.len() + flat-rows.len()
  if col-count > 0 {
    assert(
      calc.rem(total-cells, col-count) == 0,
      message: "data-table: cell count ("
        + str(total-cells)
        + ") is not divisible by column count ("
        + str(col-count)
        + "). A row likely contains a nested array.",
    )
  }

  let bg-alt = border-color.lighten(50%)
  let stroke-width = 0.5pt
  let rad = 4pt
  block(
    radius: rad,
    clip: true,
    stroke: stroke-width + border-color,
    {
      set text(hyphenate: true)
      show table.cell: it => {
        let is-flex = false
        if type(columns) == array and it.x < columns.len() {
          is-flex = type(columns.at(it.x)) == fraction
        }
        if is-flex and it.y > 0 {
          place(box(width: min-text-col, height: 0pt))
        }
        it
      }
      table(
        columns: columns,
        stroke: stroke-width + border-color,
        fill: (col, row) => {
          if row == 0 { bg-header } else if alternating-rows and calc.odd(row) {
            bg-alt
          } else { none }
        },
        inset: pad,
        ..headers.map(h => text(weight: "bold", size: header-size)[#h]),
        ..flat-rows
      )
    },
  )
}
