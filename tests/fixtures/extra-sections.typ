#import "../../src/lib.typ": project-doc, card

#let custom-render(data-path) = [
  #card[Injected Section Content for #data-path]
]

#let data = (
  project: (name: "Extra Sections Test"),
  custom: (annex: "Annex data")
)

#show: project-doc(
  data: data,
  config: (
    extra-sections: (
      (
        id: "annex-a",
        phase: "planning",
        after: "boundaries",
        data-path: "custom.annex",
        render: custom-render
      ),
    )
  )
)
