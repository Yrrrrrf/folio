= Getting Started

Welcome to Folio. In this chapter, we will walk through the minimum viable setup to generate your first document.

== Minimal Setup

Folio operates on a single declarative project dictionary. Let's create a minimal `project` dictionary with just metadata and initiation information. 

```typst
#import "@preview/folio:0.0.1": charter-doc

#let my-project = (
  metadata: (id: "P1", name: "Alpha Launch", confidentiality: "Internal"),
  initiation: (
    pitch: (problem: "Loss", solution: "Fix", value: "Gain"),
    objectives: ((name: "Growth"),),
    business_case: (benefits: "More sales")
  ),
  governance: (team: ((role: "PM", name: "You"),))
)
#show: charter-doc(my-project)
```

By passing this `my-project` dictionary into the `charter-doc` organism, Folio automatically renders a professional Project Charter document.
