#import "../core/guard.typ": section-guard
#import "../primitives/card.typ": card
#import "../primitives/data_table.typ": data-table
#import "../primitives/badge.typ": badge
#import "../primitives/metric.typ": metric

#let status_report() = section-guard("Status Report", "execution.status", status => {
  stack(
    dir: ltr,
    spacing: 2em,
    metric("Overall Health", status.at("health", default: "Unknown"), intent: if status.at("health", default: "") == "Good" { "success" } else { "warning" }),
    metric("Budget Spend", status.at("spend", default: "0%")),
    metric("Schedule Variance", status.at("variance", default: "0"))
  )
  v(1em)
  card(title: "Executive Summary")[
    #status.at("summary", default: "-")
  ]
})

#let risk_matrix() = section-guard("Risk Matrix", "registers.risk_register", risks => {
  data-table(
    columns: (auto, 1fr, auto, auto, auto),
    headers: ("ID", "Risk", "Probability", "Impact", "Status"),
    rows: risks.map(r => (
      r.at("id", default: "-"),
      r.at("description", default: "-"),
      r.at("probability", default: "-"),
      r.at("impact", default: "-"),
      badge(r.at("status", default: "Open"), intent: if r.at("status", default: "") == "Closed" { "success" } else { "danger" })
    )).flatten()
  )
})

#let issue_log() = section-guard("Issue Log", "registers.issue_log", issues => {
  data-table(
    columns: (auto, 1fr, auto, auto),
    headers: ("ID", "Issue", "Owner", "Status"),
    rows: issues.map(i => (
      i.at("id", default: "-"),
      i.at("description", default: "-"),
      i.at("owner", default: "-"),
      badge(i.at("status", default: "Open"), intent: if i.at("status", default: "") == "Resolved" { "success" } else { "warning" })
    )).flatten()
  )
})

#let change_log() = section-guard("Change Log", "registers.change_log", changes => {
  data-table(
    columns: (auto, 1fr, auto),
    headers: ("ID", "Change Description", "Approval"),
    rows: changes.map(c => (
      c.at("id", default: "-"),
      c.at("description", default: "-"),
      badge(c.at("status", default: "Pending"), intent: if c.at("status", default: "") == "Approved" { "success" } else if c.at("status", default: "") == "Rejected" { "danger" } else { "neutral" })
    )).flatten()
  )
})
