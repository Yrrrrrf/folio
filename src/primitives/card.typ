#import "../core/state.typ": folio-state
#import "../theme/resolver.typ": resolve-token, resolve-spacing

#let card(body, title: none) = context {
  let st = folio-state.get()
  
  let bg = resolve-token(st, "palette.surface.card")
  let border = resolve-token(st, "palette.surface.border")
  let pad = resolve-spacing(st, multiplier: 1.0)
  let rad = resolve-token(st, "geometry.radius.lg")
  
  rect(
    fill: bg,
    stroke: 1pt + border,
    radius: rad,
    inset: pad,
    width: 100%,
    {
      if title != none {
        text(weight: "bold", size: resolve-token(st, "typography.size.lg"))[#title]
        v(resolve-spacing(st, multiplier: 0.5))
      }
      body
    }
  )
}
