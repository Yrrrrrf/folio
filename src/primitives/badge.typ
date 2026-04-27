#import "../core/state.typ": folio-state
#import "../theme/resolver.typ": resolve-token, resolve-spacing

#let badge(body, intent: "neutral") = context {
  let st = folio-state.get()
  
  let base-color = resolve-token(st, "palette.intent." + intent)
  let bg-color = base-color.lighten(85%)
  
  let pad-h = resolve-spacing(st, multiplier: 0.5)
  let pad-v = resolve-spacing(st, multiplier: 0.25)
  let rad = resolve-token(st, "geometry.radius.sm")
  
  rect(
    fill: bg-color,
    stroke: 0.5pt + base-color,
    radius: rad,
    inset: (x: pad-h, y: pad-v),
    outset: 0pt,
    text(fill: base-color.darken(20%), weight: "bold", size: resolve-token(st, "typography.size.sm"))[#body]
  )
}
