#import "../../../util/mod.typ": get-state, list, nonempty, t
#import "../../../primitives/mod.typ": h

#let boundaries(overrides: (:)) = context {
  let s = get-state()
  let has-in = nonempty(s.data, "baselines.scope.included")
  let has-ex = nonempty(s.data, "baselines.scope.excluded")
  
  if not has-in and not has-ex { return [] }
  
  h(1, t("section.scope.title"))
  
  let in-list = list(s.data, "baselines.scope.included").map(item => [✅ #item])
  let ex-list = list(s.data, "baselines.scope.excluded").map(item => [❌ #item])
  
  if has-in and has-ex {
    grid(
      columns: (1fr, 1fr),
      gutter: 2em,
      [
        #text(weight: "bold", t("section.scope.included"))
        #v(0.5em)
        #for item in in-list [ #item \ ]
      ],
      [
        #text(weight: "bold", t("section.scope.excluded"))
        #v(0.5em)
        #for item in ex-list [ #item \ ]
      ]
    )
  } else if has-in {
    text(weight: "bold", t("section.scope.included"))
    v(0.5em)
    for item in in-list [ #item \ ]
  } else {
    text(weight: "bold", t("section.scope.excluded"))
    v(0.5em)
    for item in ex-list [ #item \ ]
  }
}
