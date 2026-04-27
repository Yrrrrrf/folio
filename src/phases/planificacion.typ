#import "../core/guard.typ": section-guard
#import "../primitives/card.typ": card
#import "../primitives/data_table.typ": data-table
#import "../primitives/badge.typ": badge
#import "../utils/formatters.typ": _money, _date

#let boundaries() = section-guard("Project Boundaries (Scope)", "baselines.scope", scope => {
  card(title: "In Scope")[
    #list(..scope.at("in_scope", default: ()))
  ]
  card(title: "Out of Scope")[
    #list(..scope.at("out_of_scope", default: ()))
  ]
})

#let milestones() = section-guard("Milestones", "baselines.schedule.milestones", ms-list => {
  data-table(
    columns: (auto, 1fr, auto),
    headers: ("Date", "Milestone", "Status"),
    rows: ms-list.map(m => (
      _date(m.at("date", default: "")),
      m.at("title", default: ""),
      badge(m.at("status", default: "Pending"), intent: if m.at("status", default: "") == "Done" { "success" } else { "neutral" })
    )).flatten()
  )
})

#let budget() = section-guard("Budget Details", "baselines.financials.budget", items => {
  data-table(
    columns: (1fr, auto),
    headers: ("Item", "Allocated Funds"),
    rows: items.map(i => (
      i.at("description", default: "-"),
      _money(i.at("amount", default: 0))
    )).flatten()
  )
})

#let gantt() = section-guard("Gantt Chart", "baselines.schedule.gantt", tasks => {
  data-table(
    columns: (1fr, auto, auto, auto),
    headers: ("Task", "Start", "End", "Progress"),
    rows: tasks.map(t => (
      t.at("name", default: "-"),
      _date(t.at("start", default: "")),
      _date(t.at("end", default: "")),
      t.at("progress", default: "0%")
    )).flatten()
  )
})

#let team() = section-guard("Project Team", "governance.team", members => {
  data-table(
    columns: (auto, 1fr, auto),
    headers: ("Role", "Name", "Contact"),
    rows: members.map(m => (
      m.at("role", default: "-"),
      m.at("name", default: "-"),
      m.at("email", default: "-")
    )).flatten()
  )
})
