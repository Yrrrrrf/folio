#let metric(
  label, 
  value, 
  val-color: black,
  pad: 0.5em,
  label-size: 0.8em,
  label-color: luma(100),
  val-size: 1.5em
) = {
  block(
    stack(
      dir: ttb,
      spacing: pad,
      text(size: label-size, fill: label-color)[#label],
      text(size: val-size, weight: "bold", fill: val-color)[#value]
    )
  )
}
