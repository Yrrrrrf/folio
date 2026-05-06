#import "../theme/resolver.typ": resolve-token, resolve-spacing
#import "../core/state.typ": folio-state

#let badge(
  body, 
  base-color: none,
  bg-color: none,
  pad-h: none,
  pad-v: none,
  rad: none,
  text-size: none
) = context {
  let st = folio-state.get()
  
  let base-color = if base-color != none { base-color } else { resolve-token(st, "palette.intent.neutral") }
  let bg-color = if bg-color != none { bg-color } else { base-color.lighten(85%) }
  let pad-h = if pad-h != none { pad-h } else { resolve-spacing(st, multiplier: 0.5) }
  let pad-v = if pad-v != none { pad-v } else { resolve-spacing(st, multiplier: 0.25) }
  let rad = if rad != none { rad } else { resolve-token(st, "geometry.radius.badge") }
  let text-size = if text-size != none { text-size } else { resolve-token(st, "typography.size.sm") }
  let stroke-width = resolve-token(st, "geometry.stroke-width.thin")

  rect(
    fill: bg-color,
    stroke: stroke-width + base-color,
    radius: rad,
    inset: (x: pad-h, y: pad-v),
    outset: 0pt,
    text(fill: base-color, weight: "bold", size: text-size)[#body]
  )
}
