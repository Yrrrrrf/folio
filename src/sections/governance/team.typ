#import "../../util/mod.typ": get-state, list, nonempty, t
#import "../../primitives/mod.typ": ftable, card, h
#import "../../theme/mod.typ": presets

#let team(overrides: (compact: false)) = context {
  let s = get-state()
  if not nonempty(s.data, "governance.team") { return [] }
  
  h(1, t("section.team.title"))
  
  let team-members = list(s.data, "governance.team")
  let compact = overrides.at("compact", default: false)
  
  let pr = presets.at(get-state().theme-preset, default: presets.formal)
  
  if compact {
    let rows = team-members.map(m => (
      m.at("name", default: ""),
      m.at("role", default: ""),
      m.at("email", default: "")
    ))
    ftable((auto, auto, 1fr), header: ("Nombre", "Rol", "Contacto"), rows: rows)
  } else {
    let cards = team-members.map(m => card([
      #text(weight: "bold", size: 1.1em)[#m.at("name", default: "")]
      #v(0.2em)
      #text(fill: pr.palette.text.secondary, m.at("role", default: ""))
      #v(0.5em)
      #text(size: 0.85em)[#m.at("email", default: "")]
    ]))
    
    grid(
      columns: (1fr, 1fr, 1fr),
      gutter: 1.5em,
      ..cards
    )
  }
}
