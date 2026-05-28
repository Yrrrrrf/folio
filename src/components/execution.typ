#import "../core/resolve.typ": get-title, resolve
#import "../core/state.typ": folio-state
#import "../theme/ui.typ": badge, card, data-table, metric
#import "../i18n/i18n.typ": status-label, t
#import "../core/refs.typ": (
  change-label, decision-label, deliverable-label, issue-label,
  link-to-assumption, link-to-compliance, link-to-deliverable, link-to-issue,
  link-to-milestone, link-to-req, link-to-risk, link-to-task, risk-label,
)

#let status-report(data-path) = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  heading(level: 2)[#get-title(data, data-path, t("section-status-report"))]

  let status = resolve(data, data-path)
  if type(status) == dictionary {
    stack(
      dir: ltr,
      spacing: 2em,
      metric(
        t("metric-overall-health"),
        status-label(status.at("health", default: "Unknown")),
        intent: if status.at("health", default: "") == "Good" {
          "success"
        } else { "warning" },
      ),
      metric(t("metric-budget-spend"), status.at("spend", default: "0%")),
      metric(t("metric-schedule-variance"), status.at(
        "variance",
        default: "0",
      )),
    )
    v(1em)
    card(title: t("card-executive-summary"))[
      #status.at("summary", default: "-")
    ]
  } else {
    [#status]
  }
}

#let risk-matrix(data-path) = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  heading(level: 2)[#get-title(data, data-path, t("section-risk-matrix"))]

  let risks = resolve(data, data-path)
  if type(risks) == array {
    data-table(
      kinds: ("id", "text", "text", "status", "status", "status"),
      headers: (
        t("col-id"),
        t("col-risk"),
        t("col-mitigation"),
        t("col-probability"),
        t("col-impact"),
        t("col-status"),
      ),
      rows: risks
        .map(r => {
          let mitigation = [#r.at("mitigation", default: "-")]

          let affects-wbs = r.at("affects_wbs", default: ())
          if type(affects-wbs) == str { affects-wbs = (affects-wbs,) }
          if affects-wbs.len() > 0 {
            mitigation += [\ *#t("rel-affects")*]
            mitigation += affects-wbs.map(link-to-task).join(", ")
          }

          let blocks-milestone = r.at("blocks_milestone", default: ())
          if type(blocks-milestone) == str {
            blocks-milestone = (blocks-milestone,)
          }
          if blocks-milestone.len() > 0 {
            mitigation += [\ *#t("rel-blocks")*]
            mitigation += blocks-milestone.map(link-to-milestone).join(", ")
          }

          // NEW: source_assumption cross-ref
          let src-assumption = r.at("source_assumption", default: none)
          if src-assumption != none {
            mitigation += [\ *#t("rel-from-assumption")*#link-to-assumption(src-assumption)]
          }

          (
            [#r.at("id", default: "-")#risk-label(r.at("id", default: "-"))],
            [
              #r.at("description", default: "-")
              #{
                let c-ids = r.at("compliance_ids", default: ())
                if type(c-ids) == str { c-ids = (c-ids,) }
                c-ids.map(id => [ #link-to-compliance(id)]).join()
              }
            ],
            mitigation,
            r.at("probability", default: "-"),
            r.at("impact", default: "-"),
            badge(
              status-label(r.at("status", default: "Open")),
              intent: if r.at(
                "status",
                default: "",
              )
                == "Closed" { "success" } else { "danger" },
            ),
          )
        })
        .flatten(),
    )
  } else {
    [#risks]
  }
}

#let issue-log(data-path) = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  heading(level: 2)[#get-title(data, data-path, t("section-issue-log"))]

  let issues = resolve(data, data-path)
  if type(issues) == array {
    data-table(
      kinds: ("id", "text", "text", "status"),
      headers: (t("col-id"), t("col-issue"), t("col-owner"), t("col-status")),
      rows: issues
        .map(i => {
          let desc = [#i.at("description", default: "-")]

          let affects-risk = i.at("affects_risk", default: ())
          if type(affects-risk) == str { affects-risk = (affects-risk,) }
          if affects-risk.len() > 0 {
            desc += [\ *#t("rel-affects-risk")*]
            desc += affects-risk.map(link-to-risk).join(", ")
          }

          let blocks-milestone = i.at("blocks_milestone", default: ())
          if type(blocks-milestone) == str {
            blocks-milestone = (blocks-milestone,)
          }
          if blocks-milestone.len() > 0 {
            desc += [\ *#t("rel-blocks")*]
            desc += blocks-milestone.map(link-to-milestone).join(", ")
          }

          // NEW: blocks_deliverable cross-ref
          let blocks-deliv = i.at("blocks_deliverable", default: ())
          if type(blocks-deliv) == str { blocks-deliv = (blocks-deliv,) }
          if blocks-deliv.len() > 0 {
            desc += [\ *#t("rel-blocks-deliverable")*]
            desc += blocks-deliv.map(link-to-deliverable).join(", ")
          }

          (
            [#i.at("id", default: "-")#issue-label(i.at("id", default: "-"))],
            desc,
            i.at("owner", default: "-"),
            badge(
              status-label(i.at("status", default: "Open")),
              intent: if i.at(
                "status",
                default: "",
              )
                == "Resolved" { "success" } else { "warning" },
            ),
          )
        })
        .flatten(),
    )
  } else {
    [#issues]
  }
}

#let change-log(data-path) = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  heading(level: 2)[#get-title(data, data-path, t("section-change-log"))]

  let changes = resolve(data, data-path)
  if type(changes) == array {
    data-table(
      kinds: ("id", "text", "status", "status", "status"),
      headers: (
        t("col-id"),
        t("col-change-desc"),
        t("col-change-type"),
        t("col-affects-baseline"),
        t("col-approval"),
      ),
      rows: changes
        .map(c => (
          [#c.at("id", default: "-")#change-label(c.at("id", default: "-"))],
          c.at("description", default: "-"),
          badge(status-label(c.at("type", default: "—")), intent: "neutral"),
          c.at("affects_baseline", default: "—"),
          badge(
            status-label(c.at("status", default: "Pending")),
            intent: if c.at(
              "status",
              default: "",
            )
              == "Approved" { "success" } else if c.at("status", default: "")
              == "Rejected" { "danger" } else { "neutral" },
          ),
        ))
        .flatten(),
    )
  } else {
    [#changes]
  }
}

#let decision-log(data-path) = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  heading(level: 2)[#get-title(data, data-path, t("section-decision-log"))]

  let decisions = resolve(data, data-path)
  if type(decisions) == array {
    data-table(
      kinds: ("id", "text", "date", "text", "status"),
      headers: (
        t("col-id"),
        t("col-decision-rationale"),
        t("col-date"),
        t("col-maker"),
        t("col-reversibility"),
      ),
      rows: decisions
        .map(d => {
          let did = d.at("id", default: "-")
          let rationale = d.at("rationale", default: "")
          let risk-id = d.at("prompted_by_risk", default: none)
          let issue-id = d.at("prompted_by_issue", default: none)

          let body = [*#d.at("description", default: "-")*]
          if rationale.len() > 0 { body += [\ _#rationale _] }
          if risk-id != none {
            body += [\ *#t("rel-prompted-by-risk")*#link-to-risk(risk-id)]
          }
          if issue-id != none {
            body += [\ *#t("rel-prompted-by-issue")*#link-to-issue(issue-id)]
          }

          (
            [#did#decision-label(did)],
            body,
            d.at("date", default: "-"),
            d.at("decision_maker", default: "-"),
            badge(
              status-label(d.at("reversibility", default: "—")),
              intent: "neutral",
            ),
          )
        })
        .flatten(),
    )
  } else {
    [#decisions]
  }
}

#let deliverables-register(data-path) = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  heading(level: 2)[#get-title(
    data,
    data-path,
    t("section-deliverables-register"),
  )]

  let deliverables = resolve(data, data-path)
  if type(deliverables) == array {
    data-table(
      kinds: ("id", "text", "text", "date", "tags", "status"),
      headers: (
        t("col-id"),
        t("col-description"),
        t("col-owner"),
        t("col-due-date"),
        t("col-requirements"),
        t("col-status"),
      ),
      rows: deliverables
        .map(d => {
          let did = d.at("id", default: "-")
          let req-ids = d.at("req_ids", default: ())
          if type(req-ids) == str { req-ids = (req-ids,) }
          (
            [#did#deliverable-label(did)],
            d.at("description", default: "-"),
            d.at("owner", default: "-"),
            d.at("due_date", default: "-"),
            if req-ids.len() > 0 { req-ids.map(link-to-req).join(", ") } else {
              "—"
            },
            badge(
              status-label(d.at("status", default: "Planned")),
              intent: if d.at(
                "status",
                default: "",
              )
                == "Accepted" { "success" } else if d.at("status", default: "")
                == "Rejected" { "danger" } else if d.at("status", default: "")
                == "In-Review" { "warning" } else { "neutral" },
            ),
          )
        })
        .flatten(),
    )
  } else {
    [#deliverables]
  }
}
