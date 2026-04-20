#import "../theme/mod.typ": presets
#import "../util/state.typ": get-state

#let metric(value, label, delta: none, tone: "neutral") = context {
  let pr = presets.at(get-state().theme-preset, default: presets.formal)
  
  let val-color = if tone == "neutral" { pr.palette.text.primary }
    else if tone == "green" { pr.palette.intent.success }
    else if tone == "red" { pr.palette.intent.danger }
    else if tone == "amber" { pr.palette.intent.warn }
    else if tone == "muted" { pr.palette.text.muted }
    else { pr.palette.text.primary }
    
  let delta-block = if delta != none {
    box(inset: (left: 0.5em), text(fill: val-color, weight: "bold", size: 0.8em, delta))
  }
  
  block[
    #text(size: pr.palette.type-scale.at("4xl", default: 36pt), weight: "bold", fill: val-color, str(value))
    #delta-block
    \
    #v(0.2em)
    #text(size: pr.palette.type-scale.at("sm", default: 12pt), fill: pr.palette.text.muted, label)
  ]
}
