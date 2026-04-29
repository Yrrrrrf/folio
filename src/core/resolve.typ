#import "fallback.typ": missing

#let resolve(data, path, fallback-name: none) = {
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
    return missing(name)
  }
  
  return current
}

#let nonempty(data, path) = {
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
  
  if not found { return false }
  if current == none { return false }
  if current == "" { return false }
  if type(current) == array and current.len() == 0 { return false }
  if type(current) == dictionary and current.pairs().len() == 0 { return false }
  return true
}

#let get-title(data, path, default-title) = {
  let current = data
  for p in path.split(".") {
    if type(current) == dictionary and p in current {
      current = current.at(p)
    } else {
      return default-title
    }
  }
  if type(current) == dictionary and "title" in current {
    return current.title
  }
  return default-title
}
