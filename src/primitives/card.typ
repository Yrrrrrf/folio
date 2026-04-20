#import "../theme/mod.typ": presets
#import "../util/state.typ": get-state

#let card(content, emphasis: "default") = context {
  let pr = presets.at(get-state().theme-preset, default: presets.formal)
  
  let fill-color = if emphasis == "muted" {
    pr.palette.surface.page
  } else if emphasis == "accent" {
    pr.palette.intent.info.lighten(95%)
  } else {
    pr.palette.surface.card
  }
  
  block(
    fill: fill-color,
    inset: 1.25em,
    radius: pr.palette.radius.lg,
    stroke: 0.5pt + pr.palette.border.default,
    width: 100%,
    content
  )
}
