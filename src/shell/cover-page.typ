#import "../util/state.typ": get-state
#import "../primitives/badge.typ": badge

#let cover-page() = context {
  let s = get-state()
  let m = s.data.metadata
  
  if m.name == "" {
    align(center + horizon)[
      #badge("Draft", tone: "amber")
      #v(2em)
      #text(size: 1.5em, fill: red.darken(20%))[MISSING PROJECT NAME]
      #v(1em)
      #m.confidentiality
    ]
    pagebreak()
    return
  }
  
  align(center + horizon)[
    #if m.client_logo != none {
      image(m.client_logo, height: 4cm)
      v(2cm)
    }
    
    #text(size: 2.5em, weight: "bold")[#m.name]
    #v(0.5em)
    
    #text(size: 1.25em, fill: gray)[
      #m.client_name
    ]
    #v(3em)
    
    #text(size: 1em)[Versión #m.version]
    #v(0.5em)
    #text(size: 1em)[#m.created_at]
    
    #v(3em)
    #badge(m.confidentiality, tone: if m.confidentiality == "Confidencial" { "danger" } else { "warning" })
  ]
  
  pagebreak()
}
