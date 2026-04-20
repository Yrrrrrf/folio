#let get(data, path, default: none) = {
  let parts = path.split(".")
  let current = data
  for part in parts {
    if type(current) != dictionary or part not in current {
      return default
    }
    current = current.at(part)
  }
  current
}

#let present(data, path) = {
  let val = get(data, path, default: none)
  if val == none { return false }
  if type(val) == dictionary and val.keys().len() == 0 { return false }
  if type(val) == array and val.len() == 0 { return false }
  if type(val) == str and val == "" { return false }
  true
}

#let list(data, path) = {
  let val = get(data, path, default: ())
  if val == none { return () }
  if type(val) == array { return val }
  (val,)
}

#let nonempty(data, path) = {
  let val = get(data, path, default: ())
  if type(val) == array and val.len() > 0 { return true }
  if type(val) == str and val.len() > 0 { return true }
  if type(val) == dictionary and val.keys().len() > 0 { return true }
  false
}
