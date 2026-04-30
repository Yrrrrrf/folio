# Folio Migration Concerns & Trade-offs

This file documents the architectural changes and features that were modified or simplified during the transition from the legacy custom Typst project to the **Folio v0.0.1** framework.

## 1. Orchestration Change
- **Legacy:** Used `main.typ` to manually `include` files from `docs/`.
- **Folio:** Uses `project-doc()` in `main.typ` to automatically discover and render sections based on the `project-data` dictionary. The `docs/` files are now redundant for the main document but are kept as examples of how to render individual phases.

## 2. Lost Styling / Custom Libs
- **_lib/_colors.typ:** Removed. Folio uses centralized theme tokens.
- **_lib/_typography.typ:** Removed. Folio manages typography via the `brand` configuration.
- **_lib/_components.typ:** Replaced by Folio primitives (`card`, `data-table`, `badge`). Custom logic for `priority-badge` and `status-chip` is now handled by the `intent` system in Folio.

## 3. Component Trade-offs
- **Gantt Chart:** The visual bar chart (using `gantty`) is currently replaced by a detailed `data-table`. A visual Gantt primitive is a planned feature.
- **Budget Breakdown:** The legacy project had a detailed table with `qty`, `unit`, and `unit_cost`. Folio's current `budget` component simplifies this to `Item` and `Amount` for universal schema compatibility.
- **Cover Page:** The specific faculty branding (UAEMéx) was removed in favor of Folio's standardized, metadata-focused cover.

## 4. Maintenance & Schema
- The data is now strictly typed and follows the PMBOK-aligned schema. Any data not matching the schema paths (e.g., `initiation.pitch`) will be ignored or flagged by the audit tool.

## 5. Hybrid Implementation
In the current Folio implementation, these concerns are no longer just external documentation. They have been injected directly into the document via the `extra-sections` configuration in `main.typ`, ensuring stakeholders are aware of the migration trade-offs directly in the Planning phase.
