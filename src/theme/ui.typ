#import "../primitives/card.typ": card as p-card
#import "../primitives/data-table.typ": data-table as p-data-table
#import "../primitives/badge.typ": badge as p-badge
#import "../primitives/metric.typ": metric as p-metric
#import "../primitives/progress-bar.typ": progress-bar as p-progress-bar
#import "../core/state.typ": folio-state
#import "resolver.typ": resolve-columns, resolve-spacing, resolve-token

#let card(body, title: none) = context {
  let st = folio-state.get()
  p-card(
    body,
    title: title,
    bg: resolve-token(st, "palette.surface.card"),
    border-color: resolve-token(st, "palette.surface.border"),
    pad: resolve-spacing(st, multiplier: 1.0),
    rad: resolve-token(st, "geometry.radius.lg"),
    title-size: resolve-token(st, "typography.size.lg"),
  )
}

#let data-table(columns: auto, kinds: none, headers: (), rows: ()) = context {
  let st = folio-state.get()
  let resolved-columns = if kinds != none {
    let tbl-tokens = resolve-token(st, "geometry.table")
    if type(tbl-tokens) != dictionary { tbl-tokens = (:) }
    resolve-columns(kinds, tbl-tokens)
  } else {
    columns
  }
  let min-text-col = resolve-token(st, "geometry.table.min-text-col")
  if type(min-text-col) != length { min-text-col = 80pt }

  p-data-table(
    columns: resolved-columns,
    headers: headers,
    rows: rows,
    border-color: resolve-token(st, "palette.surface.border"),
    bg-header: resolve-token(st, "palette.surface.card"),
    pad: resolve-spacing(st, multiplier: 0.75),
    header-size: resolve-token(st, "typography.size.sm"),
    min-text-col: min-text-col,
  )
}

#let badge(body, intent: "neutral") = context {
  let st = folio-state.get()
  let base-color = resolve-token(st, "palette.intent." + intent)
  p-badge(
    body,
    base-color: base-color,
    bg-color: base-color.lighten(85%),
    pad-h: resolve-spacing(st, multiplier: 0.5),
    pad-v: resolve-spacing(st, multiplier: 0.25),
    rad: resolve-token(st, "geometry.radius.sm"),
    text-size: resolve-token(st, "typography.size.sm"),
  )
}

#let metric(label, value, intent: none) = context {
  let st = folio-state.get()
  let val-color = if intent != none {
    resolve-token(st, "palette.intent." + intent)
  } else {
    resolve-token(st, "palette.text")
  }
  p-metric(
    label,
    value,
    val-color: val-color,
    pad: resolve-spacing(st, multiplier: 0.5),
    label-size: resolve-token(st, "typography.size.sm"),
    label-color: resolve-token(st, "palette.intent.neutral"),
    val-size: resolve-token(st, "typography.size.xl"),
  )
}

#let progress-bar(percentage, intent: none) = context {
  let st = folio-state.get()
  let fill-color = if intent != none {
    resolve-token(st, "palette.intent." + intent)
  } else {
    resolve-token(st, "palette.primary")
  }
  p-progress-bar(
    percentage,
    fill-color: fill-color,
    bg-color: resolve-token(st, "palette.surface.border"),
    h: resolve-spacing(st, multiplier: 0.5),
    rad: resolve-token(st, "geometry.radius.sm"),
  )
}
