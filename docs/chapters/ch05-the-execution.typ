#import "../../src/lib.typ": status-report-doc
#import "_fixture.typ": project
#import "../_helpers/crosswalk.typ": crosswalk

= The Execution

#crosswalk(
  pmbok: "§2.6 Delivery Performance Domain; §2.7 Measurement",
  prince2: "Risk theme; Issues theme; Progress theme",
)

The dynamic pillars run the project week-by-week.

During the execution phase, Folio enables consistent monitoring by standardizing the capture and reporting of ongoing challenges, performance data, and stakeholder communication.

== Registers

The `registers` namespace captures risks, issues, assumptions, and changes iteratively. The shape of these collections defines how actively the project engages with operational reality.

- `registers.assumptions_log`: Tracks conditions assumed to be true for planning purposes. Each entry includes an ID, description, owner, and status.
- `registers.risk_register`: A vital instrument managing potential negative impact. Each row identifies probability, impact, and a designated mitigation strategy.
- `registers.issue_log`: Captures realized risks and active blockers. Elements include a formal status, designated resolution owner, and severity rating.
- `registers.change_log`: Documents requests altering the baseline scope, schedule, or budget. It maintains transparency around approval status and overall impact.

== Governance

The `governance` namespace structures the accountability model and status reporting mechanism.

- `governance.team[]`: Enumerates core contributors, mapping defined roles to specific individuals.
- `governance.stakeholders[]`: Maps external parties by their interest and influence matrix.
- `governance.raci_matrix[]`: Defines accountability across specific milestones.
- `governance.communications[]`: Standardizes the audience, channel, and frequency of updates.
- `governance.status.rag_status`: A unified Red-Amber-Green performance metric. Note that the system leverages `src/util/rag.typ: worst-of(...)` to calculate an aggregated health score from various individual domain RAG states ensuring rigorous performance mapping.
- `governance.status.executive_summary`: Provides a high-level narrative for leadership consumption.
- `governance.status.domain_rag`: Granular RAG tracking for Schedule, Cost, Scope, and Quality.

Below is the identical Aurora project evaluated as a Week 4 Status Report:

#v(2em)
#status-report-doc(project)
