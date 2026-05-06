#let brand = (
  typography: (
    font: (
      body: ("Libertinus Serif", "Liberation Serif", "DejaVu Serif"),
      heading: ("Liberation Sans", "DejaVu Sans"),
    ),
    size: (
      body: 11pt,
      sm: 0.9em,
      md: 1em,
      lg: 1.3em,
      xl: 1.6em,
    )
  ),
  palette: (
    primary: rgb("#1e3a8a"), // Navy
    intent: (
      success: rgb("#065f46"),
      danger: rgb("#991b1b"),
      warning: rgb("#92400e"),
      neutral: rgb("#374151")
    ),
    surface: (
      background: rgb("#ffffff"),
      card: rgb("#ffffff"),
      border: rgb("#1f2937"),
      alt: rgb("#ffffff"), // No row tinting for academic
    )
  ),
  geometry: (
    radius: (
      sm: 0pt,
      md: 0pt,
      lg: 0pt,
      "none": 0pt,
      card: 0pt,
      table: 0pt,
      badge: 0pt,
      progress: 0pt,
    ),
    stroke-width: (
      thin: 0.5pt,
      normal: 1pt,
      thick: 1.5pt,
    ),
    gantt: (
      bar-height: 14pt,
      subtask-bar-height: 8pt,
      sidebar-padding: 10pt,
      sidebar-spacing: 0.8em,
    ),
    table: (
      cell-padding: 0.5em,
    ),
    page-margin: 3cm,
    paper: "a4"
  ),
  spacing: (
    base: 1.1em,
    density-multiplier: (
      compact: 0.6,
      comfortable: 1.0,
      spacious: 1.4
    )
  )
)
