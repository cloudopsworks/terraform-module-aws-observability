##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

output "grafana_name" {
  value = try(var.grafana.create, false) ? aws_grafana_workspace.this[0].name : ""
}

output "grafana_arn" {
  value = try(var.grafana.create, false) ? aws_grafana_workspace.this[0].arn : ""
}

output "grafana_endpoint" {
  value = try(var.grafana.create, false) ? aws_grafana_workspace.this[0].endpoint : ""
}

output "grafana_version" {
  value = try(var.grafana.create, false) ? aws_grafana_workspace.this[0].grafana_version : ""
}

output "prometheus" {
  value = {
    for k, v in aws_prometheus_workspace.this : k => {
      alias    = v.alias
      arn      = v.arn
      endpoint = v.prometheus_endpoint
      id       = v.id
    }
  }
}

output "scrapers" {
  value = {
    for k, v in aws_prometheus_scraper.this : k => {
      alias    = v.alias
      arn      = v.arn
      role_arn = v.role_arn
    }
  }
}