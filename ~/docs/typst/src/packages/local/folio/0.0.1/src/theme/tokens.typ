#let default-tokens = (
  typography: (
    family: ("Inter", "sans-serif"),
    size: (
      body: 10pt,
      sm: 0.85em,
      md: 1em,
      lg: 1.25em,
      xl: 1.5em,
    )
  ),
  palette: (
    primary: rgb("#2563eb"),
    intent: (
      success: rgb("#16a34a"),
      danger: rgb("#dc2626"),
      warning: rgb("#eab308"),
      neutral: rgb("#64748b")
    ),
    surface: (
      background: rgb("#ffffff"),
      card: rgb("#f8fafc"),
      border: rgb("#e2e8f0")
    )
  ),
  geometry: (
    radius: (
      sm: 2pt,
      md: 4pt,
      lg: 8pt,
      "none": 0pt
    ),
    page-margin: 2.5cm,
    paper: "a4"
  ),
  spacing: (
    base: 1em,
    density-multiplier: (
      compact: 0.5,
      comfortable: 1.0,
      spacious: 1.5
    )
  )
)
