# Folio v0.0.1

Folio is a Typst package for generating PMBOK-aligned project documentation from simple data dictionaries. It is built entirely around a single entry point, `project-doc()`, which produces a publication-grade, zero-crash PDF regardless of which data fields are present. Missing data gracefully falls back to explicit diagnostic placeholders, and an optional architectural audit dashboard can visualize your project's completeness against the PMBOK standard.

## Quickstart

```typst
#import "@local/folio:0.0.1": project-doc

#let my-project = (
  metadata: (name: "Project Zero"),
  initiation: (pitch: "This is my project pitch.")
)

#show: project-doc(my-project, config: (audit: true))

// Any custom content appended here
```

## Examples

The best way to understand Folio is to explore the example files:
- **[examples/full-project.typ](examples/full-project.typ)**: The canonical, end-to-end demo representing a comprehensive real-world project.
- **`examples/components/`**: 15 distinct Typst files showcasing every single Folio section function in pure isolation.
- **`examples/phases/`**: Check out `01-initiation.typ` or `02-planning.typ` for isolated demonstrations of standard PMBOK phases.

## Standard Sections

Folio enforces standard PMBOK order. The orchestrated pipeline covers 15 sections:

1. **Cover**
2. **Initiation**: Pitch, Business Case, Objectives
3. **Planning**: Boundaries, Milestones, Budget, Gantt, Team
4. **Execution**: Status Report, Risk Matrix, Issue Log, Change Log
5. **Closure**: Lessons Learned, Sign-Off

## Configuration Knobs

The `project-doc` function accepts a `config` dictionary with the following toggles:
- `audit` (bool): Toggles the generation of the pre-flight PMBOK completion dashboard on the very first page. Default is `false`.
- `cover` (bool|auto): Whether to show the standard document cover. Default is `auto`.
- `toc` (bool): (Reserved for future Table of Contents generation support).
- `sections` (dict): Opt-in or opt-out of specific sections. Pass a boolean for any section ID (e.g. `gantt: false` will entirely omit the Gantt block). Default is `auto` for all sections (meaning "render if data exists").

## Branding

You can override any specific piece of Folio's design tokens by supplying a `brand` dictionary. Any missing fields elegantly fall back to default token values.

```typst
#show: project-doc(
  my-project,
  brand: (
    palette: (
      primary: rgb("#ff0000"),       // Red highlights
      surface: (card: rgb("#fafafa"))// Custom card background
    ),
    typography: (
      font-family: "Inter"
    )
  )
)
```

## Known Issues

Please refer to [CONCERNS.md](CONCERNS.md) for architectural limitations and known issues.
