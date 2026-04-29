# folio — Testing & Verification

Verification for folio is empirical. We use fixtures to ensure visual and functional correctness across different use cases.

## Workflow

1. **Compile**: Run `typst compile <fixture.typ>` on any file in `tests/fixtures/`.
2. **Inspect**: Manually review the resulting PDF. Check for:
   - Proper branding (colors, fonts).
   - Correct section ordering.
   - Audit dashboard accuracy (Critical/Important/Recommended groups).
   - Orphan reference reporting (requires 2 compile passes).
3. **Snapshot**: Once a fixture's output is approved, copy it to `tests/snapshots/`.
   ```bash
   cp tests/fixtures/minimal.pdf tests/snapshots/minimal.v0.0.1.pdf
   ```

## Fixtures

- `minimal.typ`: Sparse data, verifies zero-crash and default fallback behavior.
- `project-01.typ`: Full-scale realistic project with cross-references.
- `parity.typ`: Asserts that every pipeline entry has a matching schema record.
- `orphan-deliberate.typ`: Forces orphan references to verify they are captured and displayed in the audit appendix.
- `extra-sections.typ`: Verifies injection of custom sections into the pipeline.
- `extra-checks.typ`: Verifies that `config.extra-checks` correctly populates the audit dashboard.

## Note on Orphans
Detection of orphan references (labels that don't exist) relies on Typst's layout query system. **You must compile the document twice** for the orphan table to be fully populated.
