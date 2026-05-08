# folio . JUSTFILE

LOCAL := env('HOME') / ".local/share/typst/packages/local"
VERSION := `rg version typst.toml | cut -d'"' -f2`

# ── Helpers ──────────────────────────────────────────────────────────────────

[doc("Swap all examples + tests to use @local/folio import")]
[group('Dev')]
use-local:
    #!/usr/bin/env bash
    echo "→ Switching examples & tests to @local/folio:{{ VERSION }}..."
    fd -e typ . examples/ tests/ -x sd '../src/lib.typ' '@local/folio:{{ VERSION }}' {}
    echo "✓ All .typ files now import @local/folio:{{ VERSION }}"

[doc("Swap all examples + tests back to direct ../src/lib.typ import")]
[group('Dev')]
use-dev:
    #!/usr/bin/env bash
    echo "→ Switching examples & tests back to ../src/lib.typ..."
    fd -e typ . examples/ tests/ -x sd '@local/folio:{{ VERSION }}' '../src/lib.typ' {}
    echo "✓ All .typ files now import ../src/lib.typ"

# ── Dev ───────────────────────────────────────────────────────────────────────

[doc("Clean, compile & list all PDF files")]
[group('Dev')]
test: audit-style clean compile list
    @echo "✓ Test completed"
    @fd -uu -e pdf -t f -X rm -f

[doc("Audit for hardcoded visual literals")]
[group('Dev')]
audit-style:
    #!/usr/bin/env bash
    echo "→ Auditing for hardcoded color literals..."
    VIOLATIONS=$(rg -n \
        "(rgb\(|luma\(|\b(white|black|red|green|blue|yellow|cyan|magenta|orange|purple|gray|grey|navy|aqua|teal|maroon|fuchsia|silver|olive|lime)\b)" \
        src/components/ \
        src/theme/ui.typ \
        src/core/ \
        --glob '!**/brand-packs/**' 2>/dev/null || true)
    if [ -n "$VIOLATIONS" ]; then
        echo "🔴 Style audit failed! Hardcoded literals found:"
        echo "$VIOLATIONS"
        exit 1
    fi
    echo "✓ Style audit passed"

[doc("Compile integration showcase only")]
[group('Dev')]
test-full:
    typst compile examples/full-standards.typ

[doc("Compile branding demo only")]
[group('Dev')]
test-brand:
    typst compile examples/branding-demo.typ

[doc("Compile every component fixture individually")]
[group('Dev')]
test-components:
    fd -e typ . examples/components/ -x typst compile {}

# ── CI ────────────────────────────────────────────────────────────────────────

[doc("List all PDF files")]
[group('CI')]
list:
    fd -uu -e pdf -t f

[doc("Remove all PDF files (examples + tests)")]
[group('CI')]
clean:
    @# Uses -uu to bypass .gitignore, and -X to batch-delete them all at once
    fd -uu -e pdf -t f -X rm -f
    fd -uu -e pdf -t f . tests/ -X rm -f

[doc("Compile all examples and tests")]
[group('CI')]
compile:
    @# -e typ: look for typ files
    @# -E data.typ: exclude the shared data file
    @# -x: run the command individually for EVERY match (typst only accepts 1 file at a time)
    fd -e typ -E data.typ . examples/ -x typst compile {}
    fd -e typ -E data.typ . tests/ -x typst compile {}

[doc("Compile manual.pdf for registry submission")]
[group('CI')]
manual:
    typst compile --root . docs/manual.typ docs/manual.pdf
    @echo "✓ manual.pdf compiled at docs/manual.pdf"

# ── Local / Publish ───────────────────────────────────────────────────────────

[doc("Copy folio to local Typst packages. Pass 'full' to also copy docs/examples/tests and round-trip the import paths.")]
[group('Dev')]
local mode='':
    #!/usr/bin/env bash
    set -euo pipefail
    TARGET="{{ LOCAL }}/folio/{{ VERSION }}"

    if [ "{{ mode }}" = "full" ]; then
        echo "→ [full] Swapping to @local imports for submission copy..."
        just use-local
        just manual

        echo "→ Copying folio v{{ VERSION }} into local packages (full)..."
        rm -rf "$TARGET"
        mkdir -p "$TARGET"
        rsync -rL \
            --include='src/'       --include='src/**' \
            --include='docs/'      --include='docs/**' \
            --include='examples/'  --include='examples/**' \
            --include='tests/'     --include='tests/**' \
            --include='typst.toml' \
            --include='README.md'  \
            --include='LICENSE'    \
            --exclude='*' \
            "{{ justfile_directory() }}/" "$TARGET/"
        echo "✓ folio v{{ VERSION }} copied at $TARGET (full — src + docs + examples + tests)"

        echo "→ [full] Restoring dev imports..."
        just use-dev
        echo "✓ Import paths restored to ../src/lib.typ"
    else
        echo "→ Copying folio v{{ VERSION }} into local packages (minimal)..."
        rm -rf "$TARGET"
        mkdir -p "$TARGET"
        rsync -rL \
            --include='src/'       --include='src/**' \
            --include='typst.toml' \
            --exclude='*' \
            "{{ justfile_directory() }}/" "$TARGET/"
        echo "✓ folio v{{ VERSION }} copied at $TARGET (minimal — src only)"
    fi

[doc("Run full test suite, compile manual, and print submission checklist")]
[group('CI')]
publish: test manual
    #!/usr/bin/env bash
    echo ""
    echo "─── Submission Checklist ────────────────────────────────────"
    echo "  ✓ just test passed (audit + compile)"
    echo "  ✓ manual.pdf compiled"
    echo ""
    echo "  Verify before reopening PR:"
    echo "    [ ] docs/ directory committed to repo"
    echo "    [ ] docs/manual.pdf in typst.toml exclude list"
    echo "    [ ] examples/ has a complete standalone data.typ"
    echo "    [ ] README links to docs/overview.md and examples/"
    echo ""
    echo "  When ready:"
    echo "    just local full   → test the @local import round-trip"
    echo "    gh pr reopen <number>"
    echo "    gh pr comment <number> --body 'Added docs/, manual.pdf, complete examples/'"
    echo "─────────────────────────────────────────────────────────────"
