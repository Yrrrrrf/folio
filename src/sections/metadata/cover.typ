#import "../../util/mod.typ": get-state, present
#import "../../primitives/mod.typ": badge
#import "../../theme/mod.typ": presets

#let cover(overrides: (:)) = context {
  let s = get-state()
  let m = s.data.metadata
  let pr = presets.at(s.theme-preset, default: presets.formal)
  
  if not present(s.data, "metadata.name") { return [] }
  
  let compact = overrides.at("compact", default: false)
  
  if compact {
    block(width: 100%, stroke: (bottom: 1pt + pr.palette.border.default), inset: (bottom: 1em))[
      #grid(
        columns: (1fr, auto),
        align: (left + horizon, right + top),
        [
          #text(size: 1.5em, weight: "bold")[#m.name]
          #v(0.2em)
          #text(fill: pr.palette.text.secondary)[#m.client_name]
        ],
        [
          #badge(m.confidentiality, tone: if m.confidentiality == "Confidencial" { "danger" } else { "warning" })
          #v(0.5em)
          #text(size: 0.85em, fill: pr.palette.text.muted)[v#m.version]
        ]
      )
    ]
  } else {
    // Large structural rendering (if not handled by shell.cover_page)
    align(center)[
      #text(size: 2em, weight: "bold")[#m.name]
      #v(0.5em)
      #badge(m.confidentiality, tone: if m.confidentiality == "Confidencial" { "danger" } else { "warning" })
    ]
  }
}
