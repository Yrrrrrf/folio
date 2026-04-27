#import "tokens.typ": default-tokens

#let resolve-token(st, path) = {
  let parts = path.split(".")
  
  // 1. Try to find in brand override
  let current = st.at("brand", default: (:))
  let found-in-brand = true
  for p in parts {
    if type(current) == dictionary and p in current {
      current = current.at(p)
    } else {
      found-in-brand = false
      break
    }
  }
  
  if found-in-brand {
    return current
  }

  // 2. Fallback to default tokens
  current = default-tokens
  for p in parts {
    if type(current) == dictionary and p in current {
      current = current.at(p)
    } else {
      panic("Token not found: " + path)
    }
  }
  return current
}

#let resolve-spacing(st, multiplier: 1.0) = {
  let density = st.at("brand", default: (:)).at("density", default: "comfortable")
  let base = default-tokens.spacing.base
  let d-mult = default-tokens.spacing.density-multiplier.at(density, default: 1.0)
  return base * d-mult * multiplier
}
