#import "../src/lib.typ": folio-init, card, badge, data-table, metric, progress-bar

#show: body => folio-init(
  brand: (
    density: "spacious"
  ),
  body
)

= Phase 3 Test: Atomic Primitives Styleguide

#card(title: "Project Health")[
  This is a card. Notice how the spacing is "spacious" due to the brand density override.
  
  #v(1em)
  #stack(
    dir: ltr,
    spacing: 1em,
    metric("Budget Utilization", "85%"),
    metric("Critical Bugs", "0", intent: "success"),
    metric("Days Delayed", "12", intent: "danger")
  )
  
  #v(1em)
  #progress-bar(85, intent: "primary")
]

#v(2em)

#card(title: "Status Badges")[
  #stack(
    dir: ltr,
    spacing: 1em,
    badge("Success", intent: "success"),
    badge("Warning", intent: "warning"),
    badge("Danger", intent: "danger"),
    badge("Neutral", intent: "neutral"),
  )
]

#v(2em)

#card(title: "Data Table")[
  #data-table(
    columns: (1fr, 2fr, 1fr),
    headers: ("Task", "Assignee", "Status"),
    rows: (
      "Write Docs", "Alice", badge("Done", intent: "success"),
      "Fix Bug", "Bob", badge("In Progress", intent: "warning"),
      "", "", "" // Empty texts
    )
  )
]
