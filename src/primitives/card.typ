#import "../theme/resolver.typ": resolve-token, resolve-spacing
#import "../core/state.typ": folio-state

#let card(
  body, 
  title: none,
  bg: none,
  border-color: none,
  pad: none,
  rad: none,
  title-size: none
) = context {
  let st = folio-state.get()
  
  let bg = if bg != none { bg } else { resolve-token(st, "palette.surface.card") }
  let border-color = if border-color != none { border-color } else { resolve-token(st, "palette.surface.border") }
  let pad = if pad != none { pad } else { resolve-spacing(st) }
  let rad = if rad != none { rad } else { resolve-token(st, "geometry.radius.card") }
  let title-size = if title-size != none { title-size } else { resolve-token(st, "typography.size.lg") }
  let stroke-width = resolve-token(st, "geometry.stroke-width.normal")

  rect(
    fill: bg,
    stroke: stroke-width + border-color,
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
