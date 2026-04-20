#import "../../util/mod.typ": get-state, present, t
#import "../../primitives/mod.typ": card, h

#let pitch(overrides: (:)) = context {
  let s = get-state()
  let pitch-data = s.data.initiation.pitch
  
  let has-prob = present(s.data, "initiation.pitch.problem")
  let has-sol = present(s.data, "initiation.pitch.solution")
  let has-val = present(s.data, "initiation.pitch.value")
  
  if not has-prob and not has-sol and not has-val { return [] }
  
  h(1, t("section.pitch.title"))
  
  let cols = ()
  let contents = ()
  
  if has-prob {
    cols.push(1fr)
    contents.push(card(
      [
        #text(weight: "bold")[🎯 #t("section.pitch.problem")]
        #v(0.5em)
        #pitch-data.problem
      ], emphasis: "muted"
    ))
  }
  if has-sol {
    cols.push(1fr)
    contents.push(card(
      [
        #text(weight: "bold")[💡 #t("section.pitch.solution")]
        #v(0.5em)
        #pitch-data.solution
      ]
    ))
  }
  if has-val {
    cols.push(1fr)
    contents.push(card(
      [
        #text(weight: "bold")[✨ #t("section.pitch.value")]
        #v(0.5em)
        #pitch-data.value
      ], emphasis: "accent"
    ))
  }
  
  grid(
    columns: cols,
    gutter: 1em,
    ..contents
  )
}
