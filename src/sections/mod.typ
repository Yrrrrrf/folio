#import "metadata/cover.typ": cover
#import "metadata/document-control.typ": document-control
#import "initiation/pitch.typ": pitch
#import "initiation/objectives.typ": objectives
#import "initiation/business-case.typ": business-case
#import "baselines/scope/boundaries.typ": boundaries
#import "baselines/schedule/milestones.typ": milestones
#import "baselines/financials/budget.typ": budget
#import "registers/assumptions-log.typ": assumptions-log
#import "registers/risks.typ": risks
#import "registers/issues-log.typ": issues-log
#import "registers/change-log.typ": change-log
#import "governance/team.typ": team
#import "governance/status-report.typ": status-report
#import "closure/sign-off.typ": sign-off

#let section-registry = (
  "cover": cover,
  "document-control": document-control,
  "pitch": pitch,
  "objectives": objectives,
  "business-case": business-case,
  "boundaries": boundaries,
  "milestones": milestones,
  "budget": budget,
  "assumptions-log": assumptions-log,
  "risks": risks,
  "issues-log": issues-log,
  "change-log": change-log,
  "team": team,
  "status-report": status-report,
  "sign-off": sign-off
)

#let get-section(id) = {
  section-registry.at(id, default: none)
}
