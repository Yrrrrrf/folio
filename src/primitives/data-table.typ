#let data-table(
  columns: auto, 
  headers: (), 
  rows: (),
  border-color: luma(200),
  bg-header: luma(240),
  pad: 0.75em,
  header-size: 0.9em
) = {
  table(
    columns: columns,
    stroke: 0.5pt + border-color,
    fill: (col, row) => if row == 0 { bg-header } else { none },
    inset: pad,
    ..headers.map(h => text(weight: "bold", size: header-size)[#h]),
    ..rows
  )
}
