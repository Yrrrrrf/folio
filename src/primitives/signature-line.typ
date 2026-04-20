#import "../theme/mod.typ": presets
#import "../util/state.typ": get-state

#let signature-line(name: "", role: "", date: "", width: 6cm) = context {
  let pr = presets.at(get-state().theme-preset, default: presets.formal)
  
  box(width: width)[
    #align(center)[
      #v(2cm) // Space for actual signature
      #line(length: 100%, stroke: 0.5pt + pr.palette.border.strong)
      #v(0.5em)
      #text(weight: "bold")[#name]
      #if role != "" { [\ #text(size: 0.85em, fill: pr.palette.text.muted, role)] }
      #if date != "" { [\ #text(size: 0.85em, fill: pr.palette.text.muted, date)] }
    ]
  ]
}
