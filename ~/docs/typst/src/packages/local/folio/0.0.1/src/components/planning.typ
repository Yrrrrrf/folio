#import "../core/resolve.typ": resolve, get-title
#import "../core/state.typ": folio-state
#import "../theme/ui.typ": card, data-table, badge
#import "../utils/formatters.typ": format-money, format-date
#import "../core/refs.typ": task-label, milestone-label

#let boundaries(data-path) = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  heading(level: 2)[#get-title(data, data-path, "Project Boundaries (Scope)")]
  
  let scope = resolve(data, data-path)
  if type(scope) == dictionary {
    card(title: "In Scope")[
      #list(..scope.at("in_scope", default: ()))
    ]
    card(title: "Out of Scope")[
      #list(..scope.at("out_of_scope", default: ()))
    ]
  } else {
    [#scope]
  }
}

#let milestones(data-path) = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  heading(level: 2)[#get-title(data, data-path, "Milestones")]
  
  let ms-list = resolve(data, data-path)
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
    [#ms-list]
  }
}

#let budget(data-path) = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  heading(level: 2)[#get-title(data, data-path, "Budget Details")]
  
  let items = resolve(data, data-path)
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
    [#items]
  }
}

#let gantt(data-path) = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  heading(level: 2)[#get-title(data, data-path, "Gantt Chart")]
  
  let tasks = resolve(data, data-path)
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
    [#tasks]
  }
}

#let team(data-path) = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  heading(level: 2)[#get-title(data, data-path, "Project Team")]
  
  let members = resolve(data, data-path)
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
    [#members]
  }
}
