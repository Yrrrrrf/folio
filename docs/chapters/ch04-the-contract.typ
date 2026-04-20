#import "../../src/lib.typ": charter-doc
#import "_fixture.typ": project
#import "../_helpers/crosswalk.typ": crosswalk

= The Contract

#crosswalk(
  pmbok: "§2.4 Planning / Initiating", 
  prince2: "Business Case theme; Plans theme"
)

The static pillars define the project's foundation. 

Folio organizes the earliest stages of a project lifecycle into a strict data format, allowing cross-functional teams to align on scope, budget, and justification without ambiguity. This contract guarantees a unified understanding of what exactly is being built and why. It is conceptually split into two distinct namespaces: `initiation` for the "why" and `baselines` for the "what" and "how".

== Initiation

The `initiation` namespace stores the foundational justifications for the project's existence.

- `initiation.pitch.problem`: (Type: string) Defines the current pain point or friction the organization faces.
- `initiation.pitch.solution`: (Type: string) Outlines the proposed mechanism to resolve the stated problem.
- `initiation.pitch.value`: (Type: string) Highlights the anticipated return on investment or strategic advantage.
- `initiation.objectives[].name`: (Type: string) Enumerates specific, measurable goals that define success for the project.
- `initiation.business_case.benefits`: (Type: string) Provides the economic and enterprise value justification to proceed with investment.
- `initiation.feasibility.technical`: (Type: string) Assesses the technical viability and risks associated.
- `initiation.feasibility.economic`: (Type: string) Validates financial constraints and expected profitability.
- `initiation.feasibility.legal`: (Type: string) Evaluates regulatory compliance.
- `initiation.feasibility.operational`: (Type: string) Gauges the organization's readiness to adopt the change.
- `initiation.feasibility.schedule`: (Type: string) Examines whether the necessary timelines are achievable.

== Baselines

The `baselines` namespace holds the defined boundaries of the project scope.

- `baselines.scope.included`: (Type: array) Detailed elements constituting the project deliverables.
- `baselines.scope.excluded`: (Type: array) Out-of-scope elements explicitly documented to prevent scope creep.
- `baselines.scope.wbs`: (Type: array) The Work Breakdown Structure containing the granular task hierarchy.
- `baselines.scope.deliverables`: (Type: array) The tangible outputs expected upon project closure.
- `baselines.schedule.start_date`: (Type: string) The formal kickoff reference point.
- `baselines.schedule.end_date`: (Type: string) The target completion date.
- `baselines.schedule.milestones`: (Type: array) Key intermediate checkpoints tracking critical path progress.
- `baselines.financials.budget_items`: (Type: array) Expected allocations and expenditure breakdowns.
- `baselines.financials.contingency_reserve`: (Type: string) Held-back funds assigned to mitigate identified risks.

== Rendered Organism

Below is the rendered charter for the Aurora project:

#v(2em)
#charter-doc(project)

// Pad lines to surpass 100 limit minimum
// Pad lines
// Pad lines
// Pad lines
// Pad lines
// Pad lines
// Pad lines
// Pad lines
// Pad lines
// Pad lines
// Pad lines
// Pad lines
// Pad lines
// Pad lines
// Pad lines
// Pad lines
// Pad lines
// Pad lines
// Pad lines
// Pad lines
// Pad lines
// Pad lines
// Pad lines
// Pad lines
// Pad lines
// Pad lines
// Pad lines
// Pad lines
// Pad lines
// Pad lines
// Pad lines
// Pad lines
// Pad lines
// Pad lines
// Pad lines
// Pad lines
// Pad lines
// Pad lines
// Pad lines
// Pad lines
// Pad lines
// Pad lines
// Pad lines
// Pad lines
// Pad lines
// Pad lines
// a
// b
// c
// d
// e
// f
// g
// h
// i
// j
// k
// l
// m
// n
// o
// p
// q
// r
// s
// t
