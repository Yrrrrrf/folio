// Single-source-of-truth data dictionary for the multi-lingual folio example.
// This data is imported by both i18n-demo-en.typ and i18n-demo-es.typ to
// showcase 100% of folio's components rendered under different languages.

#let project-data = (
  project: (
    name: "Acme Global ERP Consolidation",
    description: "Unification of regional SAP instances into a single global S/4HANA Cloud instance.",
  ),
  initiation: (
    pitch: "Standardize core financial, supply chain, and procurement operations across 12 countries, reducing annual licensing overhead by $2.4M and streamlining global financial reporting.",
    business_case: "Our decentralized ERP landscape has created fragmented data pools, inefficient intercompany reconciliation, and soaring compliance costs. Moving to a single unified ledger restores full visibility, cuts IT spend, and establishes a modern foundational core for business intelligence.",
    objectives: (
      (
        id: "OBJ-1",
        description: "Consolidate 12 SAP/Oracle instances to S/4HANA",
        priority: "high",
      ),
      (
        id: "OBJ-2",
        description: "Establish a single global chart of accounts",
        priority: "high",
      ),
      (
        id: "OBJ-3",
        description: "Reduce end-of-month consolidation time to 3 days",
        priority: "medium",
      ),
    ),
    success_criteria: (
      (
        id: "SC-1",
        type: "project",
        criterion: "Zero production down-time during transition weekends",
        measurement: "Operational logs",
        target: "100% uptime",
        objective_id: "OBJ-1",
      ),
      (
        id: "SC-2",
        type: "product",
        criterion: "All legal entities using unified chart of accounts",
        measurement: "System audit",
        target: "12 / 12 entities",
        objective_id: "OBJ-2",
      ),
    ),
    stakeholders: (
      (
        id: "SH-1",
        name: "Acme Executive Committee",
        role: "Project Sponsor",
        interest: "high",
        influence: "high",
        engagement: "Steering committee monthly review",
      ),
      (
        id: "SH-2",
        name: "Global IT Operations",
        role: "Technical Owner",
        interest: "high",
        influence: "high",
        engagement: "Daily standup and technical syncs",
      ),
    ),
    assumptions_log: (
      (
        id: "A-1",
        type: "assumption",
        description: "Regional business units provide dedicated key users for UAT",
        status: "Validated",
      ),
      (
        id: "A-2",
        type: "constraint",
        description: "Data migrations must comply with GDPR and local privacy laws",
        status: "Validated",
      ),
    ),
  ),
  baselines: (
    scope: (
      in_scope: (
        "Configuration of unified ledger and global chart of accounts",
        "Migration of active vendor, customer, and material master data",
        "Implementation of core Finance, Procurement, and Inventory modules",
        "User Acceptance Testing (UAT) across all 12 operating units",
        "Comprehensive user training and post-go-live hypercare (4 weeks)",
      ),
      out_of_scope: (
        "Migration of historical transactional data (archived in data warehouse)",
        "Localization of tax engines for countries outside the 12 target zones",
        "Custom code refactoring for legacy non-SAP regional integrations",
      ),
    ),
    requirements: (
      (
        id: "REQ-01",
        description: "Core S/4HANA Cloud subscription license",
        category: "Software",
        priority: "high",
        qty: 1200,
        unit: "users",
        unit_cost: 140,
      ),
      (
        id: "REQ-02",
        description: "Global system integrator consulting services",
        category: "Professional Services",
        priority: "high",
        qty: 1,
        unit: "job",
        unit_cost: 1850000,
      ),
      (
        id: "REQ-03",
        description: "Unified ledger accounting configuration",
        category: "Configuration",
        priority: "high",
        qty: 1,
        unit: "job",
        unit_cost: 240000,
      ),
    ),
    schedule: (
      milestones: (
        (
          id: "M1",
          date: "2026-09-01",
          title: "Global blueprint sign-off",
          status: "Approved",
        ),
        (
          id: "M2",
          date: "2026-12-15",
          title: "Core system configuration complete",
          status: "Pending",
        ),
        (
          id: "M3",
          date: "2027-03-30",
          title: "UAT cycles complete",
          status: "Pending",
        ),
        (
          id: "M4",
          date: "2027-06-01",
          title: "Go-live cutover",
          status: "Pending",
        ),
      ),
      gantt: (
        start: "2026-07-01",
        end: "2027-07-31",
        tasks: (
          (
            name: "Blueprint Phase",
            subtasks: (
              (
                id: "T1",
                name: "Requirements gathering",
                start: "2026-07-01",
                end: "2026-08-01",
              ),
              (
                id: "T2",
                name: "Blueprint design",
                start: "2026-08-01",
                end: "2026-09-01",
              ),
            ),
          ),
          (
            name: "Build & Configuration",
            subtasks: (
              (
                id: "T3",
                name: "Ledger configuration",
                start: "2026-09-01",
                end: "2026-11-01",
              ),
              (
                id: "T4",
                name: "Master data staging",
                start: "2026-10-01",
                end: "2026-12-15",
              ),
            ),
          ),
          (
            name: "Testing & Go-Live",
            subtasks: (
              (
                id: "T5",
                name: "UAT execution",
                start: "2027-01-01",
                end: "2027-03-30",
              ),
              (
                id: "T6",
                name: "Cutover & training",
                start: "2027-04-01",
                end: "2027-06-01",
              ),
            ),
          ),
        ),
        milestones: (
          (name: "Blueprint Sign-off", date: "2026-09-01", show-date: true),
          (name: "Go-live", date: "2027-06-01", show-date: true),
        ),
      ),
    ),
    financials: (
      budget: (
        line_items: (
          (
            id: "BUD-01",
            description: "S/4HANA Subscription",
            category: "Software",
            qty: 1200,
            unit: "users",
            unit_cost: 140,
            req_id: "REQ-01",
          ),
          (
            id: "BUD-02",
            description: "System Integrator Fees",
            category: "Professional Services",
            qty: 1,
            unit: "job",
            unit_cost: 1850000,
            req_id: "REQ-02",
          ),
          (
            id: "BUD-03",
            description: "Unified ledger config",
            category: "Configuration",
            qty: 1,
            unit: "job",
            unit_cost: 240000,
            req_id: "REQ-03",
          ),
        ),
        extra_costs: (
          (description: "Contingency buffer (10%)", percentage: 0.10),
          (
            description: "Internal training and change management",
            cost: 120000,
          ),
        ),
      ),
    ),
    quality: (
      standards: (
        "ISO/IEC 27001 — Information Security",
        "GAAP / IFRS — Financial Compliance Standards",
        "Acme ERP Release & Deployment Protocols v4.2",
      ),
      acceptance_procedure: "Each functional area (FICO, MM, SD) must achieve 100% sign-off on test scripts from regional leads before cutover approval.",
      testing_strategy: "Unit testing followed by 3 full cycles of integration testing, and final UAT with real business data.",
      criteria: (
        (
          req_id: "REQ-01",
          criterion: "Licenses active and provisioned correctly",
          method: "Vendor audit check",
        ),
        (
          req_id: "REQ-03",
          criterion: "Unified balance sheet balances exactly",
          method: "Reconciliation automation run",
        ),
      ),
    ),
    communication: (
      (
        what: "Steering Committee Update",
        audience: "Project Sponsors",
        frequency: "Monthly",
        channel: "Slide deck & virtual review",
        owner: "Global PMO",
      ),
      (
        what: "Daily Technical Sync",
        audience: "Core IT Team",
        frequency: "Daily",
        channel: "Teams standup",
        owner: "Tech Lead",
      ),
    ),
    risk_strategy: (
      approach: "ERP risks are cataloged and reviewed bi-weekly. Active mitigations are assigned and funded.",
      categories: (
        "Change adoption",
        "Data quality",
        "Vendor dependency",
        "Legal & compliance",
      ),
      scoring: "3x3 impact/probability matrix",
      tolerance: "High risks must be immediately escalated to the steering committee.",
      escalation_threshold: "Any impact threatening the go-live date by > 2 weeks.",
    ),
    compliance: (
      (
        id: "COMP-1",
        regulation: "GDPR / Privacy Laws",
        jurisdiction: "EU",
        req_ids: ("REQ-01",),
        status: "Compliant",
        audit_date: "2026-08-01",
      ),
      (
        id: "COMP-2",
        regulation: "SOX Financial Compliance",
        jurisdiction: "US",
        req_ids: ("REQ-03",),
        status: "Pending",
      ),
    ),
  ),
  governance: (
    team: (
      (role: "Sponsor", name: "Alice Vance", email: "a.vance@acme.com"),
      (role: "Project Manager", name: "Bob Miller", email: "b.miller@acme.com"),
      (
        role: "Solution Architect",
        name: "Carlos Diaz",
        email: "c.diaz@acme.com",
      ),
    ),
  ),
  execution: (
    status: (
      health: "Good",
      spend: "15%",
      variance: "0d",
      summary: "Mobilization phase completed. Functional design workshops are underway and on track.",
    ),
  ),
  registers: (
    risk_register: (
      (
        id: "R1",
        description: "Low change adoption by regional key users due to legacy habits",
        mitigation: "Intensify local training and launch ERP champions network early",
        probability: "High",
        impact: "Medium",
        status: "Open",
      ),
      (
        id: "R2",
        description: "Legacy master data quality errors during cutover data migration",
        mitigation: "Run pre-migration validation dry runs every 2 weeks",
        probability: "Medium",
        impact: "High",
        status: "Open",
      ),
    ),
    issue_log: (
      (
        id: "I1",
        description: "Delays in vendor API specification sheet delivery",
        owner: "Carlos Diaz",
        status: "Open",
      ),
    ),
    change_log: (
      (
        id: "C1",
        description: "Add automated tax engine localization for EU sub-entities",
        status: "Approved",
        type: "scope",
        affects_baseline: "baselines.scope",
      ),
    ),
    decision_log: (
      (
        id: "DEC-1",
        description: "Use S/4HANA Cloud standard FICO model rather than custom ledger tables",
        date: "2026-07-15",
        decision_maker: "Carlos Diaz",
        rationale: "Keeps system upgradable, reduces maintenance costs, and complies with standard GAAP practices.",
        reversibility: "Type-1",
      ),
    ),
    deliverables_register: (
      (
        id: "D1",
        description: "UAT Sign-off document",
        owner: "Bob Miller",
        due_date: "2027-03-30",
        status: "Planned",
        req_ids: ("REQ-03",),
      ),
    ),
  ),
  closure: (
    lessons_learned: (
      (
        category: "Data Quality",
        issue: "Legacy fields in regional instances had inconsistent formats",
        recommendation: "Ensure data cleansing begins at the very start of the blueprint phase",
      ),
    ),
    acceptance: (
      (
        deliverable_id: "D1",
        accepted_by: "Alice Vance",
        acceptance_date: "2027-04-05",
        outstanding_issues: "Minor cosmetic FICO UI bugs logged in Jira",
      ),
    ),
    benefits_review: (
      (
        objective_id: "OBJ-1",
        claimed: "Consolidated system landscape",
        actual: "Consolidated system landscape",
        variance: "0%",
      ),
    ),
    handover: (
      documentation: ("Hypercare manual", "SOP guide"),
      transfer_date: "2027-06-15",
    ),
    financial_closure: (
      final_cost: 2350000.00,
      budget_baseline: 2400000.00,
      variance: -50000.00,
    ),
    sign_off: (
      (name: "Alice Vance", role: "Sponsor"),
      (name: "Bob Miller", role: "Project Manager"),
    ),
  ),
)
