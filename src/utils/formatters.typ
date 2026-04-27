#import "../core/state.typ": folio-state
#import "../core/fallback.typ": _missing

#let _money(amount) = context {
  let st = folio-state.get()
  let loc = st.at("locale", default: "en-US")
  
  if type(amount) != int and type(amount) != float {
    return _missing("Invalid Money: " + str(amount))
  }
  
  let amount-str = str(calc.round(float(amount), digits: 2))
  let parts = amount-str.split(".")
  let int-part = parts.at(0)
  let dec-part = if parts.len() > 1 { parts.at(1) } else { "00" }
  if dec-part.len() == 1 { dec-part += "0" }
  
  let sep = if loc.starts-with("en") { "," } else { "." }
  let dec = if loc.starts-with("en") { "." } else { "," }
  
  let res = ""
  let count = 0
  let chars = int-part.clusters()
  for i in range(chars.len() - 1, -1, step: -1) {
    if count > 0 and calc.rem(count, 3) == 0 and chars.at(i) != "-" {
      res = sep + res
    }
    res = chars.at(i) + res
    count += 1
  }
  
  let currency-symbol = if loc.starts-with("en") { "$" } else { "€" }
  
  return currency-symbol + res + dec + dec-part
}

#let _date(date-str) = context {
  let st = folio-state.get()
  let loc = st.at("locale", default: "en-US")
  
  if type(date-str) != str {
    return _missing("Invalid Date: " + str(date-str))
  }
  
  let parts = date-str.split("-")
  if parts.len() != 3 {
    return _missing("Invalid Date Format: " + date-str)
  }
  
  let (y, m, d) = parts
  
  let months-en = ("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
  let months-es = ("Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Sep", "Oct", "Nov", "Dic")
  
  let m-idx = int(m) - 1
  if m-idx < 0 or m-idx > 11 {
    return _missing("Invalid Month: " + m)
  }
  
  let month-name = if loc.starts-with("es") { months-es.at(m-idx) } else { months-en.at(m-idx) }
  
  if loc.starts-with("en") {
    return month-name + " " + d + ", " + y
  } else {
    return d + " de " + month-name + ", " + y
  }
}
