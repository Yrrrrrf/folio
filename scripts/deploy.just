# ── Release Workflow ──────────────────────────────────────────────────────────
# Safe release recipes: deploy to local typst and orchestrate full publish.
# deploy is idempotent (just copies). publish is a composed pipeline.

# ── deploy ────────────────────────────────────────────────────────────────────
[doc("Copy folio to local Typst packages (~/.local/share/typst/packages/local/)")]
[group('Deploy')]
deploy:
    #!/usr/bin/env bash
    set -euo pipefail
    TARGET="{{ LOCAL }}/folio/{{ VERSION }}"
    echo "→ Deploying folio v{{ VERSION }} to $TARGET..."
    rm -rf "$TARGET"
    mkdir -p "$TARGET"
    rsync -rL \
        --include='LICENSE' \
        --include='README.md' \
        --include='typst.toml' \
        --include='src/' --include='src/**' \
        --include='examples/' --include='examples/**' \
        --include='tests/' --include='tests/**' \
        --include='docs/' --include='docs/**' \
        --exclude='*' \
        "{{ justfile_directory() }}/" "$TARGET/"
    echo "✓ folio v{{ VERSION }} deployed to $TARGET"

# ── manual ────────────────────────────────────────────────────────────────────
[doc("Compile manual.pdf for registry submission")]
[group('Deploy')]
manual:
    @echo "→ Compiling manual..."
    @typst compile --root . docs/manual.typ docs/manual.pdf
    @echo "✓ manual.pdf compiled"

# ── publish ───────────────────────────────────────────────────────────────────
# Full publish pipeline — each step must pass before the next runs.
# Sequence: swap-dev → audit-style → test → quality → manual → deploy
[doc("Full publish pipeline: swap → audit → test → quality → manual → deploy")]
[group('Deploy')]
publish: swap-preview audit-style test quality manual deploy
    #!/usr/bin/env bash
    echo ""
    echo "─── Submission Checklist ────────────────────────────────────"
    echo "  ✓ Import paths verified (preview mode)"
    echo "  ✓ Style audit passed"
    echo "  ✓ All examples and tests compiled"
    echo "  ✓ Quality gate passed (fmt + lint)"
    echo "  ✓ manual.pdf compiled"
    echo "  ✓ Deployed to local Typst packages"
    echo ""
    echo "  When ready:"
    echo "    git push origin main"
    echo "─────────────────────────────────────────────────────────────"
