#let card(
  body, 
  title: none,
  bg: white,
  border-color: luma(200),
  pad: 1em,
  rad: 8pt,
  title-size: 1.2em
) = {
  rect(
    fill: bg,
    stroke: 1pt + border-color,
    radius: rad,
    inset: pad,
    width: 100%,
    {
      if title != none {
        text(weight: "bold", size: title-size)[#title]
        v(pad * 0.5)
      }
      body
    }
  )
}
