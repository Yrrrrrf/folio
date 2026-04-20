#import "../theme/mod.typ": presets
#import "../util/state.typ": get-state

#let badge(label, tone: "neutral") = context {
  let pr = presets.at(get-state().theme-preset, default: presets.formal)
  
  let variants = (
    red: (bg: pr.palette.intent.danger, fg: pr.palette.text.inverse),
    amber: (bg: pr.palette.intent.warn, fg: pr.palette.text.inverse),
    green: (bg: pr.palette.intent.success, fg: pr.palette.text.inverse),
    info: (bg: pr.palette.intent.info, fg: pr.palette.text.inverse),
    warn: (bg: pr.palette.intent.warn, fg: pr.palette.text.inverse),
    danger: (bg: pr.palette.intent.danger, fg: pr.palette.text.inverse),
    success: (bg: pr.palette.intent.success, fg: pr.palette.text.inverse),
    neutral: (bg: pr.palette.surface.card, fg: pr.palette.text.secondary)
  )
  
  let v = variants.at(tone, default: variants.neutral)
  
  box(
    fill: v.bg,
    inset: (x: 0.5em, y: 0.25em),
    radius: pr.palette.radius.md,
    text(fill: v.fg, size: 0.85em, weight: "medium", label)
  )
}
