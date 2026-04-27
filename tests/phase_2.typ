#import "../src/lib.typ": folio-init, folio-state, _resolve, _money, _date

#show: body => folio-init(
  locale: "es-MX",
  data: (
    project: (
      name: "Folio Refactor",
      budget: 150000.50,
      start_date: "2026-04-27",
    )
  ),
  body
)

= Phase 2 Test: Fallback & Formatters

== 1. Valid Data Resolution
- *Name:* #context { _resolve(folio-state.get().data, "project.name") }
- *Budget:* #context { _money(_resolve(folio-state.get().data, "project.budget")) }
- *Start Date:* #context { _date(_resolve(folio-state.get().data, "project.start_date")) }

== 2. Missing Data Fallback
- *Missing Field:* #context { _resolve(folio-state.get().data, "project.manager") }
- *Deep Missing Field:* #context { _resolve(folio-state.get().data, "company.address.street", fallback-name: "Street Address") }

== 3. Formatter Error Resilience
- *Invalid Money Type:* #_money("A lot of money")
- *Invalid Date Format:* #_date("27-04-2026")
- *Invalid Month:* #_date("2026-15-27")
