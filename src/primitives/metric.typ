#import "../core/state.typ": folio-state
#import "../theme/resolver.typ": resolve-token, resolve-spacing

#let metric(label, value, intent: none) = context {
  let st = folio-state.get()
  
  let val-color = if intent != none {
    resolve-token(st, "palette.intent." + intent)
  } else {
    black
  }
  
  let pad = resolve-spacing(st, multiplier: 0.5)
  
  block(
    stack(
      dir: ttb,
      spacing: pad,
      text(size: resolve-token(st, "typography.size.sm"), fill: resolve-token(st, "palette.intent.neutral"))[#label],
      text(size: resolve-token(st, "typography.size.xl"), weight: "bold", fill: val-color)[#value]
    )
  )
}
