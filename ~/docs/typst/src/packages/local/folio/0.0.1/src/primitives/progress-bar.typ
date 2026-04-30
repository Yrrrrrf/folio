#let progress-bar(
  percentage, 
  fill-color: blue,
  bg-color: luma(200),
  h: 0.5em,
  rad: 4pt
) = {
  let p = calc.max(0, calc.min(100, float(str(percentage).replace("%", ""))))
  
  block(
    width: 100%,
    height: h,
    {
      rect(width: 100%, height: h, fill: bg-color, radius: rad)
      place(
        top + left,
        rect(width: p * 1%, height: h, fill: fill-color, radius: rad)
      )
    }
  )
}
