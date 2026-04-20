#let h(level, content, anchor: none) = {
  if anchor != none {
    [#heading(level: level)[#content] #label(anchor)]
  } else {
    heading(level: level)[#content]
  }
}
