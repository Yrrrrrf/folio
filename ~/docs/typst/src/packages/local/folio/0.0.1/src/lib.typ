/// Folio v0.0.1 - Public API

// 1. Orchestration
#import "core/state.typ": folio-init, folio-state
#import "core/orchestrator.typ": project-doc

// 2. Phase fns & Section fns
#import "phases/initiation.typ": business-case, cover, objectives, pitch, initiation
#import "phases/planning.typ": boundaries, budget, gantt, milestones, team, planning
#import "phases/execution.typ": change-log, issue-log, risk-matrix, status-report, execution
#import "phases/closure.typ": lessons-learned, sign-off, closure
#import "phases/custom.typ": custom

// 3. Audit
#import "core/audit.typ": data-audit, data-audit-header, data-audit-orphans

// 4. UI adapters
#import "theme/ui.typ": badge, card, data-table, metric, progress-bar

// 5. Primitives (advanced)
#import "primitives/card.typ": card as raw-card
#import "primitives/badge.typ": badge as raw-badge
#import "primitives/data-table.typ": data-table as raw-data-table
#import "primitives/metric.typ": metric as raw-metric
#import "primitives/progress-bar.typ": progress-bar as raw-progress-bar

// 6. Formatters
#import "utils/formatters.typ": format-date, format-money

// 7. Refs
#import "core/refs.typ": (
  change-label, issue-label, link-to-change, link-to-issue, link-to-milestone, link-to-risk, link-to-task,
  milestone-label, risk-label, task-label,
)

// 8. Resolution helpers
#import "core/resolve.typ": nonempty, resolve
#import "core/fallback.typ": missing
#import "core/guard.typ": section-guard
#import "theme/resolver.typ": resolve-spacing, resolve-token
