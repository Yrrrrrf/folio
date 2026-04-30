#import "@local/folio:0.0.1": budget, folio-init
#import "../project.typ": project-data

#folio-init(data: project-data)

#heading(level: 1)[Budget Overview]
#budget("baselines.financials.budget")
