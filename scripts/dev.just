# ── Development Workflow ──────────────────────────────────────────────────────
# Local iteration recipes: list, clean, compile, and import-path management.
# This file must NOT run tests, quality checks, or deploy.

# ── list ──────────────────────────────────────────────────────────────────────
[doc("List all .typ source files in the project")]
[group('Dev')]
list:
    @echo "→ Typst files in project:"
    @fd -e typ .
    @echo ""

# ── clean ─────────────────────────────────────────────────────────────────────
[doc("Remove all generated PDF files")]
[group('Dev')]
clean:
    #!/usr/bin/env bash
    set -euo pipefail
    COUNT=$(fd -uu -e pdf -t f 2>/dev/null | wc -l)
    fd -uu -e pdf -t f -X rm -f 2>/dev/null || true
    echo "✓ Cleaned ${COUNT} PDF(s)"

# ── compile ───────────────────────────────────────────────────────────────────
# Facade: compiles a directory (fd + typst) or a single file (typst).
# Always uses --root . to preserve relative path resolution.
# data.typ is excluded when compiling directories (it's not a document).
[doc("Compile a directory of .typ files or a single .typ file")]
[group('Dev')]
compile path='examples':
    #!/usr/bin/env bash
    set -euo pipefail
    TARGET="{{ path }}"

    if [ -d "$TARGET" ]; then
        echo "→ Compiling directory: $TARGET/"
        fd -e typ -E data.typ -E '*-data*' . "$TARGET/" -x typst compile --root . {}
        echo "✓ All files in $TARGET/ compiled"
    elif [ -f "$TARGET" ]; then
        echo "→ Compiling file: $TARGET"
        typst compile --root . "$TARGET"
        echo "✓ $TARGET compiled"
    else
        echo "ERROR: '$TARGET' is neither a directory nor a file"
        exit 1
    fi

# ── swap-local ────────────────────────────────────────────────────────────────
[doc("Swap imports to @local/folio (test as end user)")]
[group('Dev')]
swap-local: (_replace-imports "local")
    @echo "✓ All .typ files now import {{ PKG_ID }}"

# ── swap-dev ──────────────────────────────────────────────────────────────────
[doc("Restore relative dev imports (shipped state)")]
[group('Dev')]
swap-dev: (_replace-imports "dev")
    @echo "✓ Import paths restored to relative (dev mode)"

# ── swap-preview ────────────────────────────────────────────────────────────────
[doc("Swap imports to @preview/folio (for CI/linter)")]
[group('Dev')]
swap-preview: (_replace-imports "preview")
    @echo "✓ All .typ files now import @preview/folio:{{ VERSION }}"