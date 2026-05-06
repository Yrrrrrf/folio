#import "../theme/resolver.typ": resolve-token, resolve-spacing
#import "../core/state.typ": folio-state

#let metric(
  label, 
  value, 
  val-color: none,
  pad: none,
  label-size: none,
  label-color: none,
  val-size: none
) = context {
  let st = folio-state.get()
  
  let val-color = if val-color != none { val-color } else { resolve-token(st, "palette.primary") }
  let label-color = if label-color != none { label-color } else { resolve-token(st, "palette.intent.neutral") }
  let pad = if pad != none { pad } else { resolve-spacing(st, multiplier: 0.5) }
  let label-size = if label-size != none { label-size } else { resolve-token(st, "typography.size.sm") }
  let val-size = if val-size != none { val-size } else { resolve-token(st, "typography.size.xl") }

  block(
    stack(
      dir: ttb,
      spacing: pad,
      text(size: label-size, fill: label-color)[#label],
      text(size: val-size, weight: "bold", fill: val-color)[#value]
    )
  )
}
