#import "../core/guard.typ"
#import "../theme/ui.typ": card, data-table, badge, metric
#import "../core/refs.typ": risk-label, issue-label, change-label, link-to-task, link-to-milestone, link-to-risk
#import "../core/state.typ": folio-state
#import "../core/resolve.typ": resolve, get-title

#let status-report() = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  heading(level: 2)[#get-title(data, "execution.status", "Status Report")]
  
  let status = resolve(data, "execution.status")
  if type(status) == dictionary {
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
  } else {
    status
  }
}

#let risk-matrix() = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  heading(level: 2)[#get-title(data, "registers.risk_register", "Risk Matrix")]
  
  let risks = resolve(data, "registers.risk_register")
  if type(risks) == array {
    data-table(
      columns: (auto, 1fr, 1fr, auto, auto, auto),
      headers: ("ID", "Risk", "Mitigation", "Probability", "Impact", "Status"),
      rows: risks.map(r => {
        let mitigation = [#r.at("mitigation", default: "-")]
        
        let affects-wbs = r.at("affects_wbs", default: ())
        if type(affects-wbs) == str { affects-wbs = (affects-wbs,) }
        if affects-wbs.len() > 0 {
          mitigation += [\ *Affects:* ]
          mitigation += affects-wbs.map(link-to-task).join(", ")
        }
        
        let blocks-milestone = r.at("blocks_milestone", default: ())
        if type(blocks-milestone) == str { blocks-milestone = (blocks-milestone,) }
        if blocks-milestone.len() > 0 {
          mitigation += [\ *Blocks:* ]
          mitigation += blocks-milestone.map(link-to-milestone).join(", ")
        }
        
        (
          [#r.at("id", default: "-")#risk-label(r.at("id", default: "-"))],
          r.at("description", default: "-"),
          mitigation,
          r.at("probability", default: "-"),
          r.at("impact", default: "-"),
          badge(r.at("status", default: "Open"), intent: if r.at("status", default: "") == "Closed" { "success" } else { "danger" })
        )
      }).flatten()
    )
  } else {
    risks
  }
}

#let issue-log() = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  heading(level: 2)[#get-title(data, "registers.issue_log", "Issue Log")]
  
  let issues = resolve(data, "registers.issue_log")
  if type(issues) == array {
    data-table(
      columns: (auto, 1fr, auto, auto),
      headers: ("ID", "Issue", "Owner", "Status"),
      rows: issues.map(i => {
        let desc = [#i.at("description", default: "-")]
        
        let affects-risk = i.at("affects_risk", default: ())
        if type(affects-risk) == str { affects-risk = (affects-risk,) }
        if affects-risk.len() > 0 {
          desc += [\ *Affects Risk:* ]
          desc += affects-risk.map(link-to-risk).join(", ")
        }
        
        let blocks-milestone = i.at("blocks_milestone", default: ())
        if type(blocks-milestone) == str { blocks-milestone = (blocks-milestone,) }
        if blocks-milestone.len() > 0 {
          desc += [\ *Blocks:* ]
          desc += blocks-milestone.map(link-to-milestone).join(", ")
        }
        
        (
          [#i.at("id", default: "-")#issue-label(i.at("id", default: "-"))],
          desc,
          i.at("owner", default: "-"),
          badge(i.at("status", default: "Open"), intent: if i.at("status", default: "") == "Resolved" { "success" } else { "warning" })
        )
      }).flatten()
    )
  } else {
    issues
  }
}

#let change-log() = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  heading(level: 2)[#get-title(data, "registers.change_log", "Change Log")]
  
  let changes = resolve(data, "registers.change_log")
  if type(changes) == array {
    data-table(
      columns: (auto, 1fr, auto),
      headers: ("ID", "Change Description", "Approval"),
      rows: changes.map(c => (
        [#c.at("id", default: "-")#change-label(c.at("id", default: "-"))],
        c.at("description", default: "-"),
        badge(c.at("status", default: "Pending"), intent: if c.at("status", default: "") == "Approved" { "success" } else if c.at("status", default: "") == "Rejected" { "danger" } else { "neutral" })
      )).flatten()
    )
  } else {
    changes
  }
}
