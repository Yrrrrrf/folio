# folio

**folio** is a Typst package that turns project data into publication-grade documents. You write the data; folio writes the document.

## Quickstart

```typst
#import "@local/folio:0.0.1": project-doc

#let project = (
  project: (name: "My Project", description: "A folio demonstration"),
  initiation: (pitch: "This project will change everything.")
)

#show: project-doc(
  project,
  config: (audit: true, toc: true),
  brand: (palette: (primary: rgb("#003e7e"))),
)
```

## Features

- **The Data is the Document**: All content lives in a single dictionary.
- **Graceful Failure**: Missing fields show as red placeholders, not build errors.
- **Branding**: Override tokens for color, typography, and geometry.
- **Audit System**: Diagnostic dashboard for data completeness and orphan references.
- **Extensible**: Inject custom sections at named insertion points.

## Audit System

Folio includes a diagnostic audit system. To enable it, set `audit: true` in the config.

Note: **Orphan Reference detection** requires a second compile pass for full accuracy, as it depends on Typst's layout query system.

## Documentation

See `docs/manual.typ` for full API reference and schema details.
