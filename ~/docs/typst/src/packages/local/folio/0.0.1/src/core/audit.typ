#import "state.typ": folio-state
#import "resolve.typ": nonempty
#import "../theme/ui.typ": badge, data-table
#import "../theme/resolver.typ": resolve-token
#import "schema.typ": folio-schema
#import "refs.typ": folio-orphans

#let data-audit-header() = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  let danger = resolve-token(st, "palette.intent.danger")
  let neutral = resolve-token(st, "palette.intent.neutral")
  
  // Merge extra checks from config
  let extra-checks = st.config.at("extra-checks", default: ())
  for check in extra-checks {
    let valid-severities = ("critical", "important", "recommended")
    if check.at("severity", default: "") not in valid-severities {
      panic("Invalid severity in extra-checks: " + check.at("severity", default: "") + ". Must be one of " + str(valid-severities))
    }
  }
  let full-schema = folio-schema + extra-checks

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
    let items = full-schema.filter(r => r.severity == sev)
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
      (r.path, b, r.at("phase", default: "custom"))
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

#let data-audit-orphans() = context {
  let orphans = folio-orphans.get()
  
  heading(level: 2)[Orphan References]
  
  if orphans.len() == 0 {
    [No orphan references detected.]
  } else {
    data-table(
      columns: (1fr, 1fr),
      headers: ("Target Label", "Fallback Text"),
      rows: orphans.map(o => (
        str(o.target),
        o.fallback
      )).flatten()
    )
    v(1em)
    text(style: "italic", size: 0.8em)[Note: Orphan detection may require a second compile pass to be fully accurate.]
  }
}

#let data-audit() = {
  data-audit-header()
}
