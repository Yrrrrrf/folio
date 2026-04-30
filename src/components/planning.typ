#import "../core/resolve.typ": resolve, get-title
#import "../core/state.typ": folio-state
#import "../theme/ui.typ": card, data-table, badge, metric
#import "../utils/formatters.typ": format-money, format-date
#import "../core/refs.typ": task-label, milestone-label, req-label, link-to-req

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

#let requirements(data-path) = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  heading(level: 2)[#get-title(data, data-path, "Requirements Register")]

  let reqs = resolve(data, data-path)
  if type(reqs) != array { [#reqs]; return }

  // Group by category
  let categories = reqs.map(r => r.at("category", default: "General")).dedup()

  for cat in categories {
    let cat-reqs = reqs.filter(r => r.at("category", default: "General") == cat)
    let subtotal = cat-reqs.fold(0.0, (acc, r) => {
      let qty = float(r.at("qty", default: 1))
      let uc = float(r.at("unit_cost", default: 0))
      acc + qty * uc
    })

    card(title: cat)[
      #data-table(
        columns: (auto, 1fr, auto, auto, auto, auto),
        headers: ("ID", "Description", "Qty", "Unit", "Unit Cost", "Priority"),
        rows: cat-reqs.map(r => {
          let rid = r.at("id", default: "-")
          (
            [#rid#req-label(rid)],
            r.at("description", default: "-"),
            str(r.at("qty", default: 1)),
            r.at("unit", default: "—"),
            if r.at("unit_cost", default: 0) > 0 { format-money(r.at("unit_cost", default: 0)) } else { "—" },
            badge(r.at("priority", default: "medium"), intent: if r.at("priority", default: "") == "high" { "danger" } else if r.at("priority", default: "") == "low" { "neutral" } else { "warning" })
          )
        }).flatten()
      )
      #if subtotal > 0 {
        align(right)[*Subtotal: #format-money(subtotal)*]
      }
    ]
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

// Budget: supports both old flat (description, amount) and new rich (line_items, extra_costs) shape.
#let budget(data-path) = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  heading(level: 2)[#get-title(data, data-path, "Budget Details")]

  let raw = resolve(data, data-path)

  // Shape detection: old flat array vs. new dict shape
  if type(raw) == array {
    // Backward-compatible: flat (description, amount) array
    data-table(
      columns: (1fr, auto),
      headers: ("Item", "Allocated Funds"),
      rows: raw.map(i => (
        i.at("description", default: "-"),
        format-money(i.at("amount", default: 0))
      )).flatten()
    )
    return
  }

  if type(raw) != dictionary { [#raw]; return }

  // Rich shape: line_items grouped by category + extra_costs
  let line-items = raw.at("line_items", default: ())
  let extra-costs = raw.at("extra_costs", default: ())

  let categories = line-items.map(i => i.at("category", default: "General")).dedup()
  let line-subtotal = line-items.fold(0.0, (acc, i) => {
    acc + float(i.at("qty", default: 1)) * float(i.at("unit_cost", default: 0))
  })

  for cat in categories {
    let cat-items = line-items.filter(i => i.at("category", default: "General") == cat)
    let cat-total = cat-items.fold(0.0, (acc, i) => acc + float(i.at("qty", default: 1)) * float(i.at("unit_cost", default: 0)))

    card(title: cat)[
      #data-table(
        columns: (auto, 1fr, auto, auto, auto, auto),
        headers: ("ID", "Description", "Qty", "Unit", "Unit Cost", "Total"),
        rows: cat-items.map(i => {
          let total = float(i.at("qty", default: 1)) * float(i.at("unit_cost", default: 0))
          let req-id = i.at("req_id", default: none)
          (
            i.at("id", default: "-"),
            if req-id != none { [#i.at("description", default: "-") (#link-to-req(req-id))] } else { i.at("description", default: "-") },
            str(i.at("qty", default: 1)),
            i.at("unit", default: "—"),
            format-money(i.at("unit_cost", default: 0)),
            format-money(total)
          )
        }).flatten()
      )
      #align(right)[*Category subtotal: #format-money(cat-total)*]
    ]
  }

  if extra-costs.len() > 0 {
    card(title: "Additional Costs")[
      #data-table(
        columns: (1fr, auto),
        headers: ("Description", "Amount"),
        rows: extra-costs.map(e => {
          let amt = if e.at("percentage", default: none) != none {
            line-subtotal * float(e.at("percentage", default: 0))
          } else {
            float(e.at("cost", default: 0))
          }
          (
            e.at("description", default: "-"),
            format-money(amt)
          )
        }).flatten()
      )
    ]
  }

  let extras-total = extra-costs.fold(0.0, (acc, e) => {
    if e.at("percentage", default: none) != none {
      acc + line-subtotal * float(e.at("percentage", default: 0))
    } else {
      acc + float(e.at("cost", default: 0))
    }
  })
  let grand-total = line-subtotal + extras-total

  card[
    #stack(
      dir: ltr,
      spacing: 3em,
      metric("Line Items Subtotal", format-money(line-subtotal)),
      metric("Additional Costs", format-money(extras-total)),
      metric("Grand Total", format-money(grand-total), intent: "success")
    )
  ]
}

// Gantt: supports both old flat array and new nested (start, end, tasks, milestones) shape.
#let gantt(data-path) = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  heading(level: 2)[#get-title(data, data-path, "Gantt Chart")]

  let raw = resolve(data, data-path)

  // Old flat array: (id, name, start, end, progress)
  if type(raw) == array {
    data-table(
      columns: (1fr, auto, auto, auto),
      headers: ("Task", "Start", "End", "Progress"),
      rows: raw.map(t => {
        let tid = t.at("id", default: t.at("name", default: "-"))
        (
          [#t.at("name", default: "-")#task-label(tid)],
          format-date(t.at("start", default: "")),
          format-date(t.at("end", default: "")),
          t.at("progress", default: "0%")
        )
      }).flatten()
    )
    return
  }

  // New nested dict shape: (start, end, tasks: [(name, subtasks: [...])], milestones: [...])
  if type(raw) != dictionary { [#raw]; return }

  let proj-start = raw.at("start", default: "")
  let proj-end = raw.at("end", default: "")
  let phases = raw.at("tasks", default: ())
  let ms-markers = raw.at("milestones", default: ())

  card(title: "Schedule Overview")[
    *Project period:* #format-date(proj-start) — #format-date(proj-end)
  ]

  for ph in phases {
    card(title: ph.at("name", default: "Phase"))[
      #data-table(
        columns: (1fr, auto, auto),
        headers: ("Task", "Start", "End"),
        rows: ph.at("subtasks", default: ()).map(t => {
          let tid = t.at("id", default: t.at("name", default: "-"))
          (
            [#t.at("name", default: "-")#task-label(tid)],
            format-date(t.at("start", default: "")),
            format-date(t.at("end", default: ""))
          )
        }).flatten()
      )
    ]
  }

  if ms-markers.len() > 0 {
    card(title: "Milestones")[
      #data-table(
        columns: (1fr, auto),
        headers: ("Milestone", "Date"),
        rows: ms-markers.map(m => (
          m.at("name", default: "-"),
          format-date(m.at("date", default: ""))
        )).flatten()
      )
    ]
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

#let quality(data-path) = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  heading(level: 2)[#get-title(data, data-path, "Quality Plan")]

  let q = resolve(data, data-path)
  if type(q) != dictionary { [#q]; return }

  let standards = q.at("standards", default: ())
  if standards.len() > 0 {
    card(title: "Standards")[
      #list(..standards)
    ]
  }

  let accept-proc = q.at("acceptance_procedure", default: none)
  if accept-proc != none {
    card(title: "Acceptance Procedure")[#accept-proc]
  }

  let testing = q.at("testing_strategy", default: none)
  if testing != none {
    card(title: "Testing Strategy")[#testing]
  }

  let criteria = q.at("criteria", default: ())
  if type(criteria) == array and criteria.len() > 0 {
    card(title: "Quality Criteria")[
      #data-table(
        columns: (auto, 1fr, auto),
        headers: ("Requirement", "Criterion", "Method"),
        rows: criteria.map(c => (
          link-to-req(c.at("req_id", default: "-")),
          c.at("criterion", default: "-"),
          c.at("method", default: "-")
        )).flatten()
      )
    ]
  }
}

#let communication(data-path) = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  heading(level: 2)[#get-title(data, data-path, "Communication Plan")]

  let comms = resolve(data, data-path)
  if type(comms) == array {
    data-table(
      columns: (1fr, auto, auto, auto, auto),
      headers: ("What", "Audience", "Frequency", "Channel", "Owner"),
      rows: comms.map(c => (
        c.at("what", default: "-"),
        c.at("audience", default: "-"),
        c.at("frequency", default: "-"),
        c.at("channel", default: "-"),
        c.at("owner", default: "-")
      )).flatten()
    )
  } else {
    [#comms]
  }
}

#let risk-strategy(data-path) = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  heading(level: 2)[#get-title(data, data-path, "Risk Management Strategy")]

  let rs = resolve(data, data-path)
  if type(rs) != dictionary { [#rs]; return }

  let approach = rs.at("approach", default: none)
  if approach != none { card(title: "Approach")[#approach] }

  let cats = rs.at("categories", default: ())
  if cats.len() > 0 {
    card(title: "Risk Categories")[
      #list(..cats)
    ]
  }

  let scoring = rs.at("scoring", default: none)
  let tolerance = rs.at("tolerance", default: none)
  let threshold = rs.at("escalation_threshold", default: none)

  if scoring != none or tolerance != none or threshold != none {
    card(title: "Thresholds & Scoring")[
      #if scoring != none { [*Scoring:* #scoring \ ] }
      #if tolerance != none { [*Tolerance:* #tolerance \ ] }
      #if threshold != none { [*Escalation threshold:* #threshold] }
    ]
  }
}

#let compliance(data-path) = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  heading(level: 2)[#get-title(data, data-path, "Compliance Register")]

  let items = resolve(data, data-path)
  if type(items) == array {
    data-table(
      columns: (auto, 1fr, auto, auto, auto),
      headers: ("ID", "Regulation", "Jurisdiction", "Requirements", "Status"),
      rows: items.map(c => {
        let req-ids = c.at("req_ids", default: ())
        if type(req-ids) == str { req-ids = (req-ids,) }
        let audit-date = c.at("audit_date", default: none)
        (
          c.at("id", default: "-"),
          [*#c.at("regulation", default: "-")*#if audit-date != none { [\ Audit: #format-date(audit-date)] }],
          c.at("jurisdiction", default: "—"),
          if req-ids.len() > 0 { req-ids.map(link-to-req).join(", ") } else { "—" },
          badge(c.at("status", default: "Pending"), intent: if c.at("status", default: "") == "Compliant" { "success" } else if c.at("status", default: "") == "Non-compliant" { "danger" } else { "neutral" })
        )
      }).flatten()
    )
  } else {
    [#items]
  }
}
