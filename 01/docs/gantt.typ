#import "@local/folio:0.0.1": gantt, milestones, folio-init
#import "../project.typ": project-data

#folio-init(data: project-data)

#heading(level: 1)[Schedule]
#milestones("baselines.schedule.milestones")
#gantt("baselines.schedule.gantt")
