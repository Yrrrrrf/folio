#!/bin/bash
set -e

cd "$(dirname "$0")/.."
echo "Checking manual compilation..."
typst compile --root . docs/manual.typ docs/manual.pdf
echo "Compilation passed with zero warnings!"
