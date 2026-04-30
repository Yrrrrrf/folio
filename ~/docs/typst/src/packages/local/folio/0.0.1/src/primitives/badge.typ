#let badge(
  body, 
  base-color: luma(100),
  bg-color: luma(240),
  pad-h: 0.5em,
  pad-v: 0.25em,
  rad: 4pt,
  text-size: 0.8em
) = {
  rect(
    fill: bg-color,
    stroke: 0.5pt + base-color,
    radius: rad,
    inset: (x: pad-h, y: pad-v),
    outset: 0pt,
    text(fill: base-color, weight: "bold", size: text-size)[#body]
  )
}
