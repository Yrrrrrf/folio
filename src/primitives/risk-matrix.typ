#import "../theme/mod.typ": presets
#import "../util/state.typ": get-state

#let risk-matrix(
  risks: (),
  levels: ("low", "medium", "high"),
) = context {
  let pr = presets.at(get-state().theme-preset, default: presets.formal)
  
  let n = levels.len()
  let cell-size = 40pt
  
  // Grid configuration
  // n+1 columns (one for Y axis labels)
  // n+1 rows (one for X axis labels)
  
  let grid-items = ()
  
  // Probability (Y-axis) increases from bottom to top
  // Levels are e.g. ("low", "medium", "high")
  // So top row is "high", bottom row is "low"
  
  for row-idx in range(n).rev() {
    let prob-level = levels.at(row-idx)
    
    // Y-axis label
    grid-items.push(align(right + horizon, text(size: 0.8em, weight: "bold", prob-level)))
    
    for col-idx in range(n) {
      let imp-level = levels.at(col-idx)
      
      // Calculate severity for coloring
      // severity = (level_index_p+1) × (level_index_i+1)
      let p_score = row-idx + 1
      let i_score = col-idx + 1
      let score = p_score * i_score
      
      let fill-color = if score >= 6 {
        rgb("#ffcdd2") // Red 100
      } else if score >= 3 {
        rgb("#fff9c4") // Yellow 100
      } else {
        rgb("#c8e6c9") // Green 100
      }
      
      let border-color = if score >= 6 {
        rgb("#e53935") // Red 600
      } else if score >= 3 {
        rgb("#fbc02d") // Yellow 700
      } else {
        rgb("#43a047") // Green 600
      }

      // Find risks in this bucket
      let bucket-risks = risks.filter(r => r.at("probability") == prob-level and r.at("impact") == imp-level)
      
      grid-items.push(
        rect(
          width: 100%,
          height: cell-size,
          fill: fill-color,
          stroke: 0.5pt + border-color,
          radius: 2pt,
          inset: 4pt,
          align(center + horizon, 
            stack(dir: ltr, spacing: 2pt, ..bucket-risks.map(r => 
              text(size: 0.7em, weight: "bold", fill: border-color.darken(20%), r.at("id"))
            ))
          )
        )
      )
    }
  }
  
  // X-axis labels (Impact)
  grid-items.push([]) // Corner
  for col-idx in range(n) {
    let imp-level = levels.at(col-idx)
    grid-items.push(align(center + top, text(size: 0.8em, weight: "bold", imp-level)))
  }

  block(breakable: false, {
    // Labels for axes
    // Y Axis label (Probability)
    // X Axis label (Impact)
    
    grid(
      columns: (auto, 1fr),
      gutter: 10pt,
      align(horizon, rotate(-90deg, text(weight: "bold", size: 0.9em, "Probabilidad"))),
      stack(
        spacing: 5pt,
        grid(
          columns: (auto,) + (1fr,) * n,
          column-gutter: 4pt,
          row-gutter: 4pt,
          ..grid-items
        ),
        align(center, text(weight: "bold", size: 0.9em, "Impacto"))
      )
    )
  })
}
