#import "../core/guard.typ"
#import "../theme/ui.typ": card, data-table, badge
#import "../utils/formatters.typ": format-money, format-date
#import "../core/refs.typ": task-label, milestone-label
#import "../core/state.typ": folio-state
#import "../core/resolve.typ": resolve, get-title

#let boundaries() = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  heading(level: 2)[#get-title(data, "baselines.scope", "Project Boundaries (Scope)")]
  
  let scope = resolve(data, "baselines.scope")
  if type(scope) == dictionary {
    card(title: "In Scope")[
      #list(..scope.at("in_scope", default: ()))
    ]
    card(title: "Out of Scope")[
      #list(..scope.at("out_of_scope", default: ()))
    ]
  } else {
    scope
  }
}

#let milestones() = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  heading(level: 2)[#get-title(data, "baselines.schedule.milestones", "Milestones")]
  
  let ms-list = resolve(data, "baselines.schedule.milestones")
  if type(ms-list) == array {
    data-table(
      columns: (auto, 1fr, auto),
      headers: ("Date", "Milestone", "Status"),
      rows: ms-list.map(m => {
        let mid = m.at("id", default: m.at("title", default: ""))
        (
          format-date(m.at("date", default: "")),
          [#m.at("title", default: "")#milestone-label(mid)],
          badge(m.at("status", default: "Pending"), intent: if m.at("status", default: "") == "Done" { "success" } else { "neutral" })
        )
      }).flatten()
    )
  } else {
    ms-list
  }
}

#let budget() = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  heading(level: 2)[#get-title(data, "baselines.financials.budget", "Budget Details")]
  
  let items = resolve(data, "baselines.financials.budget")
  if type(items) == array {
    data-table(
      columns: (1fr, auto),
      headers: ("Item", "Allocated Funds"),
      rows: items.map(i => (
        i.at("description", default: "-"),
        format-money(i.at("amount", default: 0))
      )).flatten()
    )
  } else {
    items
  }
}

#let gantt() = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  heading(level: 2)[#get-title(data, "baselines.schedule.gantt", "Gantt Chart")]
  
  let tasks = resolve(data, "baselines.schedule.gantt")
  if type(tasks) == array {
    data-table(
      columns: (1fr, auto, auto, auto),
      headers: ("Task", "Start", "End", "Progress"),
      rows: tasks.map(t => {
        let tid = t.at("id", default: t.at("name", default: "-"))
        (
          [#t.at("name", default: "-")#task-label(tid)],
          format-date(t.at("start", default: "")),
          format-date(t.at("end", default: "")),
          t.at("progress", default: "0%")
        )
      }).flatten()
    )
  } else {
    tasks
  }
}

#let team() = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  heading(level: 2)[#get-title(data, "governance.team", "Project Team")]
  
  let members = resolve(data, "governance.team")
  if type(members) == array {
    data-table(
      columns: (auto, 1fr, auto),
      headers: ("Role", "Name", "Contact"),
      rows: members.map(m => (
        m.at("role", default: "-"),
        m.at("name", default: "-"),
        m.at("email", default: "-")
      )).flatten()
    )
  } else {
    members
  }
}
