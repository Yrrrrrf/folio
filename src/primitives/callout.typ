#import "../theme/mod.typ": presets
#import "../util/state.typ": get-state

#let callout(content, kind: "info", title: none, icon: auto) = context {
  let pr = presets.at(get-state().theme-preset, default: presets.formal)
  
  let variants = (
    info: (bg: pr.palette.intent.info.lighten(90%), border: pr.palette.intent.info, icon: "ℹ️"),
    warn: (bg: pr.palette.intent.warn.lighten(90%), border: pr.palette.intent.warn, icon: "⚠️"),
    danger: (bg: pr.palette.intent.danger.lighten(90%), border: pr.palette.intent.danger, icon: "🚨"),
    success: (bg: pr.palette.intent.success.lighten(90%), border: pr.palette.intent.success, icon: "✅"),
    neutral: (bg: pr.palette.surface.card, border: pr.palette.border.default, icon: "📝")
  )
  
  let v = variants.at(kind, default: variants.neutral)
  let actual-icon = if icon == auto { v.icon } else { icon }
  
  block(
    fill: v.bg,
    stroke: (left: 4pt + v.border),
    inset: 1em,
    width: 100%,
    radius: (right: pr.palette.radius.sm, left: 0pt),
    [
      #if title != none {
        text(weight: "bold")[#actual-icon #title]
        v(0.5em)
      } else {
        if actual-icon != none { text(weight: "bold")[#actual-icon ] }
      }
      #content
    ]
  )
}
