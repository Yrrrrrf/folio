# Folio Roadmap: Lessons from Project 01

The migration of Project 01 from a custom Typst implementation to Folio v0.0.1 has revealed several high-value enhancement opportunities. This roadmap documents features that would bridge the gap between Folio's standardization and the specialized needs of complex technical projects.

## 1. Advanced Financial Primitive (`budget-plus`)
- **Requirement:** Legacy `01.txt` had detailed tables with `qty`, `unit`, `unit_cost`, and `subtotal`.
- **Enhancement:** Add a `budget-plus` component that accepts an array of objects with these fields and automatically calculates subtotals and grand totals.
- **Calculated Extras:** Support for dynamic "Service Fees" or "Contingency" as percentages of the subtotal.

## 2. Integrated Visual Gantt
- **Requirement:** Users value the visual bar chart for high-level timeline communication.
- **Enhancement:** Internalize a visual Gantt renderer (inspired by `gantty`) that works directly with Folio's flat task list, removing the need for external package imports in `main.typ`.

## 3. Thematic "Intents" & Status Mapping
- **Requirement:** Legacy project used custom color logic for `priority-badge` and `status-chip`.
- **Enhancement:** Allow the `brand` configuration to define a mapping between data values (e.g., "Alta", "En Progreso") and Folio's internal intents (`danger`, `success`, `warning`).

## 4. Institutional Branding Templates
- **Requirement:** The "UAEMéx" header/footer and cover were highly specific.
- **Enhancement:** Support a `template` config option that swaps out the core `cover()`, `header`, and `footer` logic for pre-defined institutional layouts (e.g., `academic`, `corporate`, `minimal`).

## 5. Automated Variance Analysis
- **Requirement:** Project management often requires comparing "Planned" vs "Actual".
- **Enhancement:** Update the `execution.status` schema to support `actual_start`, `actual_end`, and `actual_spend`, then provide a `variance-report` component that calculates delays and overruns.

## 6. Document Variants (Presets)
- **Requirement:** Different projects need different sections (e.g., a Thesis doesn't need a Risk Register).
- **Enhancement:** Provide "Config Presets" like `config: folio-presets.thesis` or `config: folio-presets.construction-proposal` that pre-toggle sections and labels.

## 7. Interactive Data Audit
- **Requirement:** Current audit lists missing fields.
- **Enhancement:** Improve the audit UI to provide "Reasoning" (e.g., "Critical for PMBOK Compliance") and actionable links to where the data should be added.
