#import "../theme/mod.typ": presets
#import "../util/state.typ": get-state

// Very basic date to integer conversion (days since 2000-01-01) for proportional scaling
#let to-days(ds) = {
  if type(ds) != str { return 0 }
  let parts = ds.split("-")
  if parts.len() != 3 { return 0 }
  let (y, m, d) = parts
  int(y) * 365 + int(m) * 30 + int(d)
}

#let timeline-bar(start-iso, end-iso, range-start-iso, range-end-iso, label: none, tone: "brand") = context {
  let pr = presets.at(get-state().theme-preset, default: presets.formal)
  
  let t-start = to-days(start-iso)
  let t-end = to-days(end-iso)
  let r-start = to-days(range-start-iso)
  let r-end = to-days(range-end-iso)
  
  let total = calc.max(1, r-end - r-start)
  
  // clamp
  let act-start = calc.max(r-start, calc.min(t-start, r-end))
  let act-end = calc.max(r-start, calc.min(t-end, r-end))
  
  let offset-pct = (act-start - r-start) / total * 100
  let width-pct = (act-end - act-start) / total * 100
  
  let fill-color = if tone == "brand" { pr.palette.brand.accent } else { pr.palette.brand.primary }
  
  if t-start == 0 or t-end == 0 {
    return []
  }
  
  box(width: 100%, height: 1.2em)[
    // Background ruler
    #place(left+horizon, box(width: 100%, height: 0.1em, fill: pr.palette.surface.overlay))
    #place(
      left+horizon, 
      dx: offset-pct * 1%, 
      box(width: width-pct * 1%, height: 0.8em, fill: fill-color, radius: pr.palette.radius.sm)
    )
    #if label != none {
      place(
        left+top,
        dx: offset-pct * 1%,
        dy: -1em,
        text(size: 0.7em, fill: pr.palette.text.muted, label)
      )
    }
  ]
}
