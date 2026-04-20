#import "../../util/mod.typ": get-state, list, nonempty, t
#import "../../primitives/mod.typ": progress, h

#let objectives(overrides: (:)) = context {
  let s = get-state()
  
  if not nonempty(s.data, "initiation.objectives") { return [] }
  
  h(1, t("section.objectives.title"))
  
  let objs = list(s.data, "initiation.objectives")
  
  for obj in objs {
    let title = obj.at("name", default: "Objetivo")
    let target = obj.at("target", default: 100)
    
    if "progress" in obj {
      let prog = obj.progress
      grid(
        columns: (1fr, 60%),
        align: horizon,
        gutter: 1em,
        [• #title],
        progress(prog, max: target)
      )
      v(0.5em)
    } else {
      [• #title \ ]
    }
  }
}
