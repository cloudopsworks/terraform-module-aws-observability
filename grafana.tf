##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

data "aws_iam_policy_document" "grafana_assume_role" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type        = "Service"
      identifiers = ["grafana.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "grafana" {
  name               = "grafana-${local.system_name}-role"
  assume_role_policy = data.aws_iam_policy_document.grafana_assume_role.json
}

resource "aws_grafana_workspace" "this" {
  name                      = try(var.grafana.name, "") != "" ? var.grafana.name : format("%s-%s-grafana", var.grafana.name_prefix, local.system_name)
  account_access_type       = try(var.grafana.account_access_type, "CURRENT_ACCOUNT")
  authentication_providers  = try(var.grafana.authentication_providers, [])
  permission_type           = try(var.grafana.permission_type, "SERVICE_MANAGED")
  role_arn                  = aws_iam_role.grafana.arn
  configuration             = length(try(var.grafana.configuration, {})) > 0 ? jsonencode(var.grafana.configuration) : null
  data_sources              = try(var.grafana.data_sources, null)
  notification_destinations = try(var.grafana.notification_destinations, null)
  organization_role_name    = try(var.grafana.organization_role_name, null)
  organizational_units      = try(var.grafana.organizational_units, null)
  dynamic "vpc_configuration" {
    for_each = length(try(var.vpc, {})) > 0 ? [1] : []
    content {
      security_group_ids = try(var.vpc.security_group_ids, null)
      subnet_ids         = try(var.vpc.subnet_ids, null)
    }
  }
  tags = local.all_tags
}
