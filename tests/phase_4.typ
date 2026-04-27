#import "../src/lib.typ": folio-init, section-guard, data-table

#show: body => folio-init(
  data: (
    inventory: (
      items: (
        (name: "Laptop", qty: 5),
        (name: "Monitor", qty: 2),
      )
    )
  ),
  body
)

= Phase 4 Test: The Guard Pattern

#section-guard("Inventario (Faltante)", "baselines.inventory", items => {
  [This should not be printed.]
})

#section-guard("Inventario (Con Datos)", "inventory.items", items => {
  data-table(
    columns: (1fr, 1fr),
    headers: ("Item", "Quantity"),
    rows: items.map(i => (i.name, str(i.qty))).flatten()
  )
})
