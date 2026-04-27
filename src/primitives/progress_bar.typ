#import "../core/state.typ": folio-state
#import "../theme/resolver.typ": resolve-token, resolve-spacing

#let progress-bar(percentage, intent: "primary") = context {
  let st = folio-state.get()
  
  let fill-color = if intent == "primary" {
    resolve-token(st, "palette.primary")
  } else {
    resolve-token(st, "palette.intent." + intent)
  }
  
  let bg-color = resolve-token(st, "palette.surface.border")
  let h = resolve-spacing(st, multiplier: 0.5)
  let rad = resolve-token(st, "geometry.radius.sm")
  
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
