/// Folio v0.0.1 — Public API
/// Import this module to use folio. Internal machinery is not exposed here.

// ── Entry point ──────────────────────────────────────────────────────────────
#import "core/orchestrator.typ": project-doc
// folio-init: public for custom pipeline / standalone component use
#import "core/state.typ": folio-init

// ── Phase-level functions (orchestrate a whole phase) ───────────────────────
#import "phases/initiation.typ": initiation
#import "phases/planning.typ": planning
#import "phases/execution.typ": execution
#import "phases/closure.typ": closure
#import "phases/custom.typ": custom

// ── Section-level functions (individual PMBOK sections) ─────────────────────
// Initiation
#import "components/initiation.typ": cover, pitch, business-case, objectives, success-criteria, stakeholders, assumptions-log
// Planning
#import "components/planning.typ": boundaries, requirements, milestones, budget, gantt, quality, communication, risk-strategy, compliance, team
// Execution
#import "components/execution.typ": status-report, risk-matrix, issue-log, change-log, decision-log, deliverables-register
// Closure
#import "components/closure.typ": lessons-learned, sign-off, acceptance, benefits-review, handover, financial-closure

// ── Themed UI primitives (token-resolved, use these in custom sections) ──────
#import "theme/ui.typ": badge, card, data-table, metric, progress-bar

// ── Raw primitives (explicit params, for power users) ───────────────────────
#import "primitives/card.typ": card as raw-card
#import "primitives/badge.typ": badge as raw-badge
#import "primitives/data-table.typ": data-table as raw-data-table
#import "primitives/metric.typ": metric as raw-metric
#import "primitives/progress-bar.typ": progress-bar as raw-progress-bar

// ── Formatters ───────────────────────────────────────────────────────────────
#import "utils/formatters.typ": format-date, format-money, format-percent

// ── Cross-reference utilities ────────────────────────────────────────────────
#import "core/refs.typ": (
  task-label, milestone-label, risk-label, issue-label, change-label,
  req-label, deliverable-label, assumption-label, decision-label,
  stakeholder-label, objective-label, compliance-label,
  link-to-task, link-to-milestone, link-to-risk, link-to-issue, link-to-change,
  link-to-req, link-to-deliverable, link-to-assumption, link-to-decision,
  link-to-stakeholder, link-to-objective, link-to-compliance,
)

// ── Compute layer (pure functions — data → values) ───────────────────────────
#import "compute.typ": (
  sum-costs,
  line-subtotal, extras-total, grand-total,
  calc-budget, calc-requirements,
  find-orphans, audit-missing, audit-summary,
  compute-context,
)

// ── Validator convenience wrappers (context-aware compute) ───────────────────
#import "utils/validators.typ": orphan-check, missing-fields, audit-builder
