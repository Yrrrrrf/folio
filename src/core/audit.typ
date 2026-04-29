#import "state.typ": folio-state
#import "resolve.typ": nonempty
#import "../theme/ui.typ": badge, data-table
#import "../theme/resolver.typ": resolve-token
#import "schema.typ": folio-schema

#let data-audit() = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  let danger = resolve-token(st, "palette.intent.danger")
  let neutral = resolve-token(st, "palette.intent.neutral")
  
  let check-path(p) = {
    let current = data
    let parts = p.split(".")
    let found = true
    
    for part in parts {
      if type(current) == dictionary and part in current {
        current = current.at(part)
      } else {
        found = false
        break
      }
    }
    
    if not found {
      return "Missing"
    } else if not nonempty(data, p) {
      return "Empty"
    } else {
      return "Present"
    }
  }

  let render-group(sev, title) = {
    let items = folio-schema.filter(r => r.severity == sev)
    if items.len() == 0 { return none }
    
    let rows = items.map(r => {
      let stat = check-path(r.path)
      let b = if stat == "Present" {
        badge("Present", intent: "success")
      } else if stat == "Empty" {
        badge("Empty", intent: "warning")
      } else {
        badge("Missing", intent: "danger")
      }
      (r.path, b, r.phase)
    }).flatten()
    
    v(1em)
    heading(level: 3)[#title]
    data-table(
      columns: (1fr, auto, auto),
      headers: ("Path", "Status", "Phase"),
      rows: rows
    )
  }

  block(
    width: 100%,
    stroke: 4pt + danger,
    inset: 1.5em,
    fill: danger.lighten(90%),
    radius: 4pt
  )[
    #align(center)[
      #text(fill: danger, weight: "bold", size: 1.5em)[⚠ DIAGNOSTIC DRAFT — DO NOT SHIP]
    ]
    #v(1em)
    #text(style: "italic")[This dashboard indicates data completeness based on the PMBOK standard. Turn off by setting `config: (audit: false)`.]
    
    #render-group("critical", "Critical Data")
    #render-group("important", "Important Data")
    #render-group("recommended", "Recommended Data")
  ]
}
