#import "../theme/mod.typ": presets
#import "../util/state.typ": get-state

#let progress(value, max: 100, tone: "brand") = context {
  let pr = presets.at(get-state().theme-preset, default: presets.formal)
  
  let v = calc.max(0, calc.min(value, max))
  let pct-raw = if max > 0 { v / max * 100 } else { 0 }
  let pct = str(calc.round(pct-raw)) + "%"
  
  let fill-color = if tone == "brand" {
    pr.palette.brand.primary
  } else if tone == "red" {
    pr.palette.intent.danger
  } else if tone == "amber" {
    pr.palette.intent.warn
  } else if tone == "green" {
    pr.palette.intent.success
  } else {
    pr.palette.text.muted
  }
  
  grid(
    columns: (1fr, auto),
    gutter: 1em,
    align: horizon,
    [
      #box(width: 100%, height: 0.5em, radius: pr.palette.radius.full, fill: pr.palette.surface.overlay)[
        #box(width: pct-raw * 1%, height: 100%, radius: pr.palette.radius.full, fill: fill-color)
      ]
    ],
    text(size: 0.85em, fill: pr.palette.text.muted, pct)
  )
}
