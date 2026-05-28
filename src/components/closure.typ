#import "../core/resolve.typ": get-title, resolve
#import "../core/state.typ": folio-state
#import "../theme/ui.typ": badge, card, data-table, metric
#import "../utils/formatters.typ": format-date, format-money
#import "../core/refs.typ": link-to-deliverable, link-to-objective
#import "../i18n/i18n.typ": status-label, t

#let lessons-learned(data-path) = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  heading(level: 2)[#get-title(data, data-path, t("section-lessons-learned"))]

  let lessons = resolve(data, data-path)
  if type(lessons) == array {
    data-table(
      kinds: ("status", "text", "text"),
      headers: (
        t("col-category"),
        t("col-what-went-wrong"),
        t("col-recommendation"),
      ),
      rows: lessons
        .map(l => (
          l.at("category", default: "-"),
          l.at("issue", default: "-"),
          l.at("recommendation", default: "-"),
        ))
        .flatten(),
    )
  } else {
    [#lessons]
  }
}

#let sign-off(data-path) = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  heading(level: 2)[#get-title(data, data-path, t("section-sign-off"))]

  let stakeholders = resolve(data, data-path)
  if type(stakeholders) == array {
    data-table(
      kinds: ("text", "text", "text"),
      headers: (t("col-stakeholder"), t("col-role"), t("col-date-signature")),
      rows: stakeholders
        .map(s => (
          s.at("name", default: "-"),
          s.at("role", default: "-"),
          "___________________",
        ))
        .flatten(),
    )
  } else {
    [#stakeholders]
  }
}

#let acceptance(data-path) = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  heading(level: 2)[#get-title(data, data-path, t("section-acceptance"))]

  let records = resolve(data, data-path)
  if type(records) == array {
    data-table(
      kinds: ("id", "text", "date", "text"),
      headers: (
        t("col-deliverable"),
        t("col-accepted-by"),
        t("col-acceptance-date"),
        t("col-outstanding-issues"),
      ),
      rows: records
        .map(r => (
          link-to-deliverable(r.at("deliverable_id", default: "-")),
          r.at("accepted_by", default: "-"),
          format-date(r.at("acceptance_date", default: "")),
          r.at("outstanding_issues", default: "None"),
        ))
        .flatten(),
    )
  } else {
    [#records]
  }
}

#let benefits-review(data-path) = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  heading(level: 2)[#get-title(data, data-path, t("section-benefits-review"))]

  let reviews = resolve(data, data-path)
  if type(reviews) == array {
    data-table(
      kinds: ("id", "text", "text", "num", "text"),
      headers: (
        t("col-objective-ref"),
        t("col-claimed-benefit"),
        t("col-actual-outcome"),
        t("col-variance"),
        t("col-root-cause"),
      ),
      rows: reviews
        .map(r => (
          link-to-objective(r.at("objective_id", default: "-")),
          r.at("claimed", default: "-"),
          r.at("actual", default: "-"),
          r.at("variance", default: "-"),
          r.at("root_cause", default: "—"),
        ))
        .flatten(),
    )
  } else {
    [#reviews]
  }
}

#let handover(data-path) = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  heading(level: 2)[#get-title(data, data-path, t("section-handover"))]

  let h = resolve(data, data-path)
  if type(h) != dictionary {
    [#h]
    return
  }

  let docs = h.at("documentation", default: ())
  if docs.len() > 0 {
    card(title: t("card-docs-handed-over"))[
      #list(..docs)
    ]
  }

  let training = h.at("training", default: none)
  if training != none { card(title: t("card-training"))[#training] }

  let support = h.at("support", default: none)
  if support != none { card(title: t("card-support-warranty"))[#support] }

  let transfer-date = h.at("transfer_date", default: none)
  if transfer-date != none {
    card[*#t("chrome-transfer-date")*#format-date(transfer-date)]
  }
}

#let financial-closure(data-path) = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  heading(level: 2)[#get-title(data, data-path, t("section-financial-closure"))]

  let fc = resolve(data, data-path)
  if type(fc) != dictionary {
    [#fc]
    return
  }

  let final-cost = float(fc.at("final_cost", default: 0))
  let baseline = float(fc.at("budget_baseline", default: 0))
  let variance = float(fc.at("variance", default: final-cost - baseline))

  card[
    #stack(
      dir: ltr,
      spacing: 3em,
      metric(t("metric-budget-baseline"), format-money(baseline)),
      metric(t("metric-final-cost"), format-money(final-cost)),
      metric(t("metric-variance"), format-money(variance), intent: if variance
        <= 0 {
        "success"
      } else { "danger" }),
    )
  ]

  let explanation = fc.at("variance_explanation", default: none)
  if explanation != none {
    card(title: t("card-variance-explanation"))[#explanation]
  }

  let outstanding = fc.at("outstanding_invoices", default: none)
  if outstanding != none {
    card(title: t("card-outstanding-invoices"))[#outstanding]
  }
}
