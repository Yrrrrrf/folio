#import "../tokens.typ": tokens

#let formal-palette = (
  text: (primary: tokens.color.gray.at("900"), secondary: tokens.color.gray.at("600"), muted: tokens.color.gray.at("500"), inverse: rgb("#ffffff")),
  surface: (page: rgb("#ffffff"), card: tokens.color.gray.at("50"), elevated: rgb("#ffffff"), overlay: rgb("#0000000d")),
  border: (default: tokens.color.gray.at("200"), strong: tokens.color.gray.at("400"), focus: tokens.color.blue.at("500")),
  brand: (primary: tokens.color.blue.at("700"), accent: tokens.color.teal.at("600")),
  status: (red: tokens.color.red.at("600"), amber: tokens.color.amber.at("500"), green: tokens.color.green.at("600"), neutral: tokens.color.gray.at("500")),
  intent: (info: tokens.color.blue.at("600"), warn: tokens.color.amber.at("600"), danger: tokens.color.red.at("700"), success: tokens.color.green.at("700")),
  radius: tokens.radius
)
