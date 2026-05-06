#import "../theme/resolver.typ": resolve-token, resolve-spacing
#import "../core/state.typ": folio-state

#let progress-bar(
  percentage, 
  fill-color: none,
  bg-color: none,
  h: none,
  rad: none
) = context {
  let st = folio-state.get()
  
  let fill-color = if fill-color != none { fill-color } else { resolve-token(st, "palette.primary") }
  let bg-color = if bg-color != none { bg-color } else { resolve-token(st, "palette.surface.border") }
  let h = if h != none { h } else { resolve-spacing(st, multiplier: 0.5) }
  let rad = if rad != none { rad } else { resolve-token(st, "geometry.radius.progress") }

  let p = calc.max(0, calc.min(100, float(str(percentage).replace("%", ""))))
  
  block(
    width: 100%,
    height: h,
    {
      rect(width: 100%, height: h, fill: bg-color, radius: rad, stroke: none)
      place(
        top + left,
        rect(width: p * 1%, height: h, fill: fill-color, radius: rad, stroke: none)
      )
    }
  )
}
