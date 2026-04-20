#import "tokens.typ": tokens

#let font-stacks = (
  sans: ("Inter", "Helvetica", "Arial", "sans-serif"),
  serif: ("Source Serif 4", "Georgia", "serif"),
  mono: ("JetBrains Mono", "Menlo", "monospace")
)

#let resolve-type(scale-name) = {
  tokens.type-scale.at(scale-name, default: tokens.type-scale.base)
}
