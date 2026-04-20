# Folio

[![Typst Package](https://img.shields.io/badge/typst-package-239DAD.svg)](https://typst.app/universe/package/folio)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Folio is a declarative, state-driven project management report generator built entirely in Typst. 

Features a six-layer architecture designed to render automated templates reliably without manually wiring styles, avoiding manual spacing, sizing, or parameter-threading in business logic. Write your project data once, and generate PMBOK® 7 and PRINCE2® 7 compliant documents dynamically.

[**📖 Read the full Manual PDF here**](docs/manual.pdf)

## Architecture at a glance

Folio maps standard project management concepts into a strict six-namespace data contract, then uses that single source of truth to render different "organisms" (documents).

```text
┌──────────────────────┐
│  dt.typ (Data)       │
│  - metadata          │
│  - initiation        │
│  - baselines         │
│  - registers         │
│  - governance        │
│  - closure           │
└──────────┬───────────┘
           │
           ├────────────────────────┐
           ▼                        ▼
┌────────────────────┐   ┌────────────────────┐
│ #charter(project)  │   │ #status-report(...)│
└────────────────────┘   └────────────────────┘
```

## Quick Start

Initialize your project dictionary and pass it to an organism. Here is a minimal Charter:

```typst
#import "@preview/folio:0.0.1": charter

#let my-project = (
  metadata: (
    name: "Aurora Project", 
    confidentiality: "Internal",
    tags: ("Cloud", "Migration")
  ),
  initiation: (
    pitch: (
      problem: "Legacy infra is slow.", 
      solution: "Migrate to cloud.", 
      value: "Increase agility."
    )
  )
)

#show: charter(my-project)
```

## Supported Organisms & Standards

| Organism | PMBOK® 7 Ref | PRINCE2® 7 Theme | Consumes Namespaces | Status |
|----------|--------------|------------------|---------------------|--------|
| `charter` | Project Charter | Business Case | `metadata`, `initiation`, `baselines` | Stable |
| `status-report` | Communications | Risk/Issue, Progress | `metadata`, `registers`, `governance` | Stable |
| *(planned)* `closure-doc` | Close Project | End Project Report | *closure* | Roadmap |

## Documentation

The full documentation is structured as a Typst-native book demonstrating the six-namespace architecture. It culminates in live-rendered examples of the charter and status report using a shared full-scale PM fixture.

👉 [**Download the Manual (docs/manual.pdf)**](docs/manual.pdf)
