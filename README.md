# Folio v0.0.1 (Reborn)

Folio is a declarative, state-driven project management report generator built entirely in Typst. 

Features a six-layer architecture designed to render automated templates reliably without manually wiring styles, avoiding `#v`, `text(size: ...)` or parameter-threading in business logic.

## Quickstart

Configure your business document using deep nested data and standard PMBOK concepts, and pass it directly to one of the defined organisms.

```typst
#import "@local/folio:0.0.1": charter-doc

#let my-project = (
  metadata: (name: "Aurora Project", confidentiality: "Internal"),
  initiation: (
    pitch: (problem: "...", solution: "...", value: "...")
  )
)

#show: charter-doc(my-project)
```

## Running Examples Locally

To exercise the standard implementations, explore the `examples` directory:

```bash
# Render a comprehensive Project Charter
typst compile --root . examples/01-minimal-charter/main.typ

# Render a concise Executive Status Report showing multi-kind section reuse
typst compile --root . examples/02-status-report/main.typ

# Verify gracefully degraded draft stamping on missing dependencies
typst compile --root . examples/03-degraded/main.typ
```
