#import "coerce.typ": present

#let check-required(data, paths) = {
  paths.filter(p => not present(data, p))
}

#let check-recommended(data, paths) = {
  paths.filter(p => not present(data, p))
}
