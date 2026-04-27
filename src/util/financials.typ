#let line-items-subtotal(items) = {
  if items == none { return 0 }
  items.map(it => it.at("qty", default: 0) * it.at("unit_cost", default: 0)).sum(default: 0)
}

#let categorize(items) = {
  if items == none { return () }
  let categories = ()
  for it in items {
    let cat = it.at("category", default: "Uncategorized")
    if cat not in categories {
      categories.push(cat)
    }
  }

  categories.map(cat => {
    let cat-items = items.filter(it => it.at("category", default: "Uncategorized") == cat)
    (
      category: cat,
      items: cat-items,
      subtotal: line-items-subtotal(cat-items)
    )
  })
}

#let resolve-extras(extras, subtotal) = {
  if extras == none { return () }
  extras.map(ex => {
    let amount = if ex.at("kind", default: "fixed") == "pct_of_subtotal" {
      subtotal * ex.at("value", default: 0)
    } else {
      ex.at("value", default: 0)
    }
    (name: ex.at("name", default: "Extra"), amount: amount)
  })
}

#let grand-total(subtotal, resolved-extras, contingency_reserve) = {
  subtotal + resolved-extras.map(ex => ex.amount).sum(default: 0) + (if contingency_reserve == none { 0 } else { contingency_reserve })
}
