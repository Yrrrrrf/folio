#import "schema-data.typ": schema-rows, crosswalk-matrix, glossary-terms
#import "../../src/lib.typ": ftable
#import "../../src/primitives/badge.typ": badge

#let render-schema-table() = {
  for ns in ("metadata", "initiation", "baselines", "registers", "governance", "closure") {
    heading(level: 3, ns)
    let ns-rows = schema-rows.filter(r => r.path.starts-with(ns + "."))
    
    let r_arr = ns-rows.map(r => (
      raw(r.path),
      r.type,
      if r.required { badge("Yes", tone: "success") } else { badge("No", tone: "neutral") },
      raw(r.default),
      r.description
    ))

    ftable(
      (2.5fr, 1fr, 0.9fr, 1.2fr, 3fr),
      header: ("Path", "Type", "Req", "Default", "Description"),
      rows: r_arr
    )
    v(1em)
  }
}

#let render-crosswalk-matrix() = {
  let r_arr = crosswalk-matrix.map(r => (
    strong(r.namespace),
    r.pmbok,
    r.prince2,
    r.iso
  ))

  ftable(
    (1.2fr, 1fr, 1fr, 1.2fr),
    header: ("Namespace", "PMBOK®", "PRINCE2®", "ISO"),
    rows: r_arr
  )
}

#let render-glossary() = {
  for term in glossary-terms.sorted(key: t => t.term) {
    block(
      width: 100%,
      inset: (bottom: 1em),
      [
        #text(weight: "bold", size: 1.1em)[#term.term] #if term.aka != "" [ _(aka #term.aka)_ ]\
        #term.definition
      ]
    )
  }
}
