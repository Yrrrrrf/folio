#import "../src/lib.typ": *
#import "../src/util/state.typ": set-state

#let project = (
  metadata: (
    name: "Folio v0.0.1",
    client_name: "Documentation & Reference Manual",
    version: "0.0.1",
    created_at: "2026-04-20",
    confidentiality: "Public",
    client_logo: none
  )
)

#show: doc => {
  set-state(locale: "en-US", data: project)
  set page(paper: "us-letter", margin: 1in)
  set text(size: 10pt)
  
  cover-page()
  toc(title: "Table of Contents", depth: 3)
  
  pagebreak()
  
  [
    = Preface

    Welcome to Folio. This manual is structured around Folio's core philosophy: a single source of truth for all your project management artifacts.
  ]
  pagebreak()

  doc
}

#include "chapters/ch01-getting-started.typ"
#include "chapters/ch02-foundations.typ"
#include "chapters/ch03-metadata.typ"
#include "chapters/ch04-the-contract.typ"
#include "chapters/ch05-the-execution.typ"
#include "chapters/ch06-closure.typ"
#include "chapters/ch07-reference.typ"
