/// Folio v2.0 - Public API

// 1. Initialization
/// Initializes the global state and standardizes document variables.
#import "core/state.typ": folio-init

// 2. Lifecycle Modules
#import "phases/inicio.typ": pitch, business_case, objectives, cover
#import "phases/planificacion.typ": boundaries, milestones, budget, gantt, team
#import "phases/ejecucion.typ": status_report, risk_matrix, issue_log, change_log
#import "phases/cierre.typ": lessons_learned, sign_off

// 3. UI Primitives (For advanced layout building)
#import "primitives/card.typ": card
#import "primitives/badge.typ": badge
#import "primitives/data_table.typ": data-table
#import "primitives/metric.typ": metric
#import "primitives/progress_bar.typ": progress-bar

// 4. Core & Formatters (For debugging and custom Guards)
#import "core/guard.typ": section-guard
#import "core/state.typ": folio-state
#import "theme/resolver.typ": resolve-token, resolve-spacing
#import "core/fallback.typ": _missing
#import "core/resolve.typ": _resolve
#import "utils/formatters.typ": _money, _date
