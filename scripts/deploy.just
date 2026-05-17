# ── Release Workflow ──────────────────────────────────────────────────────────
# deploy-local   → ~/.local/share/typst/packages/local/folio/<ver>   (with tests)
# deploy-preview → <typst-packages>/packages/preview/folio/<ver>     (no tests)
# deploy         → both
#
# Shared filter rules:
#   Kept:    LICENSE, README.md, typst.toml, src/**, examples/**.typ,
#            docs/manual.{typ,pdf}
#   Dropped: every *.pdf except docs/manual.pdf (build artifacts),
#            scripts/, pi-dt/, flake.*, MANIFEST.md, justfile, …

# ── _deploy-to ────────────────────────────────────────────────────────────────
# Private rsync helper. `with_tests` is "true" (include tests/) or "false".
[private]
_deploy-to target with_tests:
    #!/usr/bin/env bash
    set -euo pipefail
    TARGET="{{ target }}"
    echo "  → $TARGET"
    rm -rf "$TARGET"
    mkdir -p "$TARGET"

    # Conditional tests/ filter — bash array safely expands to nothing when empty
    TESTS_FILTER=()
    if [ "{{ with_tests }}" = "true" ]; then
        TESTS_FILTER+=(--include='tests/***')
    fi

    # Order matters: rsync uses first-match-wins.
    # 1) Whitelist the one PDF we keep BEFORE the blanket *.pdf exclude.
    # 2) Blanket *.pdf exclude strips every other build artifact.
    # 3) Tree-includes (src, examples, [tests]) pick up everything else.
    # 4) Final --exclude='*' drops anything not whitelisted above.
    rsync -rL \
        --include='LICENSE' \
        --include='README.md' \
        --include='typst.toml' \
        --include='docs/' \
        --include='docs/*' \
        --include='docs/manual.pdf' \
        --exclude='*.pdf' \
        --include='src/***' \
        --include='examples/***' \
        "${TESTS_FILTER[@]}" \
        --exclude='*' \
        "{{ justfile_directory() }}/" "$TARGET/"

# ── deploy-local ──────────────────────────────────────────────────────────────
[doc("Copy folio to ~/.local/share/typst/packages/local/  (includes tests/)")]
[group('Deploy')]
deploy-local: (_deploy-to (LOCAL / "folio" / VERSION) "true")
    @echo "✓ folio v{{ VERSION }} → @local/folio:{{ VERSION }}"

# ── deploy-preview ────────────────────────────────────────────────────────────
[doc("Copy folio to typst-packages/packages/preview/  (no tests, manual.pdf only)")]
[group('Deploy')]
deploy-preview: (_deploy-to (PREVIEW / "folio" / VERSION) "false")
    @echo "✓ folio v{{ VERSION }} → @preview/folio:{{ VERSION }}"

# ── deploy ────────────────────────────────────────────────────────────────────
[doc("Deploy to both local AND preview package directories")]
[group('Deploy')]
deploy: deploy-local deploy-preview
    @echo "✓ folio v{{ VERSION }} deployed (local + preview)"