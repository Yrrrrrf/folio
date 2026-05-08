# folio · Build System

Modular build system for the folio Typst package. Run `just -l` from the project root to see all available recipes.

## Architecture

```
justfile                    ← Entry point (imports only)
scripts/
├── _shared.just           ← Private: import replacement logic
├── dev.just               ← Development: list, clean, compile, swap
├── ci.just                ← Quality: fmt, lint, quality
├── test.just              ← Testing: test, test-fixture, test-brand, ...
└── deploy.just            ← Release: deploy, manual, publish
```

## Workflows

### Daily Development

```bash
just list                  # See all .typ files
just compile               # Compile examples/ (default)
just compile tests         # Compile tests/
just compile path/to/f.typ # Compile a single file
just clean                 # Remove all PDFs
```

### Testing as End User

```bash
just swap-local            # Switch to @local/folio:0.0.1 imports
just compile examples      # Verify examples work with published package
just swap-dev              # Restore relative dev imports
```

### Quality Checks

```bash
just fmt                   # Format with typstyle
just lint                  # Lint via compile check
just quality               # Both: fmt + lint
```

### Testing

```bash
just test              # Compile all examples + tests
just test-fixture NAME     # Compile one fixture (e.g., minimal-data)
just test-brand            # Test brand presets
just test-components       # Test all component examples
just audit-style           # Check for hardcoded color literals
```

### Release

```bash
just deploy                # Copy to local Typst packages
just manual                # Compile docs/manual.pdf
just publish               # Full pipeline: swap-dev → audit → test → quality → manual → deploy
```

## Key Principles

1. **Default state is relative imports** — what Typst Universe sees
2. **Git is the undo mechanism** — no .bak files
3. **Import swapping is centralized** — one regex, one place (`_shared.just`)
4. **Compile is a facade** — handles both directories and files
5. **Publish is composed** — each step is independently callable

## Troubleshooting

| Problem | Solution |
|---|---|
| `swap-local` fails | Ensure `sd` is installed (`cargo install sd`) |
| `compile` can't find src | Run from project root; verify `--root .` resolves |
| `deploy` fails | Check `~/.local/share/typst/packages/local/` is writable |
| `test-fixture` not found | Use the name without `.typ` (e.g., `just test-fixture minimal-data`) |
| `fmt` fails | Ensure `typstyle` is installed (included in flake.nix dev shell) |
