#import "tokens.typ": default-tokens

#let resolve-token(st, path) = {
  let parts = path.split(".")
  
  // 1. Try to find in user brand override
  let user-brand = st.at("brand", default: (:))
  let current = user-brand
  let found = true
  for p in parts {
    if type(current) == dictionary and p in current {
      current = current.at(p)
    } else {
      found = false
      break
    }
  }
  if found { return current }

  // 2. Try to find in preset tokens
  let preset-tokens = st.at("preset-tokens", default: (:))
  current = preset-tokens
  found = true
  for p in parts {
    if type(current) == dictionary and p in current {
      current = current.at(p)
    } else {
      found = false
      break
    }
  }
  if found { return current }

  // 3. Fallback to default tokens
  current = default-tokens
  for p in parts {
    if type(current) == dictionary and p in current {
      current = current.at(p)
    } else {
      return rgb("#ff00ff") // Fail Gracefully
    }
  }
  return current
}

#let resolve-spacing(st, multiplier: 1.0) = {
  // We resolve the base spacing through the normal chain first
  let base = resolve-token(st, "spacing.base")
  if type(base) != length { base = 1em } // Safety fallback if token resolve failed
  
  // Density multiplier also goes through the chain
  let density = st.at("brand", default: (:)).at("density", default: "comfortable")
  let d-mults = resolve-token(st, "spacing.density-multiplier")
  let d-mult = if type(d-mults) == dictionary { d-mults.at(density, default: 1.0) } else { 1.0 }
  
  return base * d-mult * multiplier
}
