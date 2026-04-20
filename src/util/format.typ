#import "state.typ": get-state
#import "coerce.typ"

#let currency(minor, locale: auto, currency-code: auto) = context {
  let s = get-state()
  let loc = if locale == auto { s.locale } else { locale }
  
  if type(minor) != int { return str(minor) }
  
  // Format minor to major handling signs
  let m = calc.abs(minor)
  let int_part = calc.trunc(m / 100)
  let dec_part = calc.rem(m, 100)
  
  let dec_str = if dec_part < 10 { "0" + str(dec_part) } else { str(dec_part) }
  let formatted = if loc == "es-MX" {
    // Basic formatting for now
    "$" + str(int_part) + "." + dec_str + " MXN"
  } else {
    "$" + str(int_part) + "." + dec_str
  }
  
  if minor < 0 { "-" + formatted } else { formatted }
}

#let date(iso, locale: auto, style: "medium") = context {
  let s = get-state()
  let loc = if locale == auto { s.locale } else { locale }
  
  if type(iso) != str { return iso }
  let parts = iso.split("-")
  if parts.len() != 3 { return iso }
  
  let (y, m, d) = parts
  
  if loc == "es-MX" {
    let months = ("ene", "feb", "mar", "abr", "may", "jun", "jul", "ago", "sep", "oct", "nov", "dic")
    let mn = int(m)
    if mn > 0 and mn <= 12 { d + " " + months.at(mn - 1) + " " + y } else { iso }
  } else {
    let months = ("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
    let mn = int(m)
    if mn > 0 and mn <= 12 { months.at(mn - 1) + " " + d + ", " + y } else { iso }
  }
}

#let number(n, locale: auto, decimals: 0) = context {
  str(n)
}

#let percent(n, locale: auto, decimals: 0) = context {
  str(calc.round(n * 100, digits: decimals)) + "%"
}
