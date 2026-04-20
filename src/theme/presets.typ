#import "../util/state.typ": get-state, set-state
#import "palettes/formal.typ": formal-palette

#let presets = (
  formal: (palette: formal-palette, font-family: "sans", density: "comfortable", page-margins: (x: 2cm, y: 2.5cm))
)

#let apply-preset(name: auto) = (doc) => context {
  let active-name = if name == auto { get-state().theme-preset } else { name }
  let pr = presets.at(active-name, default: presets.formal)
  // Ensure we also save the preset name in the state if explicitly set
  // This cannot be done inside context returning show rules directly, so the compose engine does it.
  
  show heading: set text(fill: pr.palette.text.primary, weight: "bold")
  show link: set text(fill: pr.palette.brand.primary)
  show figure: set block(spacing: 1.5em)
  
  doc
}
