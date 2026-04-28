#import "../src/lib.typ": data-audit, folio-init

#show: body => folio-init(
  data: (
    project: (name: "Test Project"),
    initiation: (pitch: "Test Pitch"),
  ),
  body,
)

#data-audit()

Here is a simple message.
