# ── Quality Assurance Workflow ─────────────────────────────────────────────────
# Static code quality recipes: formatting, linting, and the combined quality gate.
# This file must NOT compile, test, or deploy.

[doc("Format all Typst source files with typstyle")]
[group('CI')]
fmt:
    @typstyle -i . -v
    @echo "✓ Formatting complete"

[doc("Check formatting + compile all examples and tests")]
[group('CI')]
lint:
    @typstyle --check . -v
    @echo "✓ Lint complete"

[doc("Run full quality gate (format + lint)")]
[group('CI')]
quality: fmt lint
    @echo "✓ Quality gate passed"
