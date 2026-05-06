#import "@local/folio:0.0.1": badge, card, data-table, folio-init, metric, progress-bar

#set page(height: auto, margin: 1cm)

= Branding Demo

#let demo-content() = {
  stack(
    dir: ttb,
    spacing: 1.5em,
    card(title: "Sample Card")[
      This is a card with some content. It should respect the brand's radius and colors.
    ],
    badge("Success", intent: "success"),
    badge("Warning", intent: "warning"),
    badge("Danger", intent: "danger"),
    data-table(
      headers: ("Task", "Status", "Owner"),
      rows: (
        ("Design", badge("Done", intent: "success"), "Alice"),
        ("Build", badge("In Progress", intent: "warning"), "Bob"),
        ("Test", badge("Pending", intent: "neutral"), "Charlie"),
      ),
    ),
    metric("Grand Total", "$125,000", intent: "success"),
    progress-bar(65, intent: "primary"),
  )
}

== Corporate (Default)
#folio-init(brand: (preset: "corporate"))[
  #demo-content()
]

#v(4em)
#line(length: 100%, stroke: 0.5pt + luma(200))
#v(2em)

== Academic
#folio-init(brand: (preset: "academic"))[
  #demo-content()
]

#v(4em)
#line(length: 100%, stroke: 0.5pt + luma(200))
#v(2em)

== Academic + Override (Red)
#folio-init(brand: (preset: "academic", palette: (primary: rgb("#7a1f1f"))))[
  #demo-content()
]
