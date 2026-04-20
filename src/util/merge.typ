#let deep-merge(base, overlay) = {
  let result = base
  for (k, v) in overlay.pairs() {
    if type(v) == dictionary and k in result and type(result.at(k)) == dictionary {
      result.insert(k, deep-merge(result.at(k), v))
    } else {
      result.insert(k, v)
    }
  }
  result
}
