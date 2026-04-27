#import "fallback.typ": _missing

#let _resolve(data, path, fallback-name: none) = {
  let current = data
  let parts = path.split(".")
  let found = true
  
  for p in parts {
    if type(current) == dictionary and p in current {
      current = current.at(p)
    } else {
      found = false
      break
    }
  }
  
  if not found or current == none or current == "" {
    let name = fallback-name
    if name == none {
      name = path
    }
    return _missing(name)
  }
  
  return current
}
