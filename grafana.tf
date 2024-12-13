##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

locals {
  grafana_name = try(var.grafana.name, "") != "" ? var.grafana.name : format("%s-%s-grafana", var.grafana.name_prefix, local.system_name)
}

data "aws_iam_policy_document" "grafana_assume_role" {
  count = try(var.grafana.create, false) ? 1 : 0
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
  count              = try(var.grafana.create, false) ? 1 : 0
  name               = "grafana-${local.system_name}-role"
  description        = "IAM Role for Grafana workspace ${local.grafana_name}"
  assume_role_policy = data.aws_iam_policy_document.grafana_assume_role[0].json
  tags = merge(
    local.all_tags,
    {
      Name = "grafana-${local.system_name}-role"
    }
  )
}

data "aws_iam_policy_document" "grafana" {
  count = try(var.grafana.create, false) ? 1 : 0
  statement {
    sid    = "AllowAPS"
    effect = "Allow"
    actions = [
      "aps:ListWorkspaces",
    ]
    resources = ["arn:aws:aps:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:/workspaces"]
  }
  statement {
    sid    = "AllowAPSs"
    effect = "Allow"
    actions = [
      "aps:DescribeWorkspace",
    ]
    resources = ["arn:aws:aps:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:/workspace/*"]
  }
}

resource "aws_iam_role_policy" "grafana" {
  count  = try(var.grafana.create, false) ? 1 : 0
  role   = aws_iam_role.grafana[0].name
  policy = data.aws_iam_policy_document.grafana[0].json
}

resource "aws_grafana_workspace" "this" {
  count                     = try(var.grafana.create, false) ? 1 : 0
  name                      = local.grafana_name
  account_access_type       = try(var.grafana.account_access_type, "CURRENT_ACCOUNT")
  authentication_providers  = try(var.grafana.authentication_providers, [])
  permission_type           = try(var.grafana.permission_type, "SERVICE_MANAGED")
  role_arn                  = aws_iam_role.grafana[0].arn
  configuration             = length(try(var.grafana.configuration, {})) > 0 ? jsonencode(var.grafana.configuration) : null
  data_sources              = try(var.grafana.data_sources, null)
  notification_destinations = try(var.grafana.notification_destinations, null)
  organization_role_name    = try(var.grafana.organization_role_name, null)
  organizational_units      = try(var.grafana.organizational_units, null)
  grafana_version           = try(var.grafana.grafana_version, null)
  description               = try(var.grafana.description, "Grafana workspace for ${local.grafana_name}")
  dynamic "vpc_configuration" {
    for_each = length(try(var.vpc, {})) > 0 ? [1] : []
    content {
      security_group_ids = concat(try(var.vpc.security_group_ids, []), try(var.vpc.create_security_group, false) ? [aws_security_group.grafana[0].id] : [])
      subnet_ids         = try(var.vpc.subnet_ids, null)
    }
  }
  tags = local.all_tags
}

resource "aws_security_group" "grafana" {
  count       = try(var.vpc.create_security_group, false) ? 1 : 0
  name        = "${local.grafana_name}-grafana-sg"
  description = "Security group for ${local.grafana_name} access to Grafana"
  vpc_id      = try(var.vpc.vpc_id, null)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ssoadmin_instances" "sso" {
  count = try(var.grafana.create, []) != [] ? 1 : 0
}

data "aws_identitystore_group" "group" {
  for_each = toset(flatten([
    for role in try(var.grafana.aws_sso, []) : [
      for group in try(role.groups, []) : group
    ] if try(var.grafana.create, false)
  ]))
  identity_store_id = tolist(data.aws_ssoadmin_instances.sso[0].identity_store_ids)[0]
  alternate_identifier {
    unique_attribute {
      attribute_path  = "DisplayName"
      attribute_value = each.value
    }
  }
}

data "aws_identitystore_user" "user" {
  for_each = toset(flatten([
    for role in try(var.grafana.aws_sso, []) : [
      for user in try(role.users, []) : user
    ] if try(var.grafana.create, false)
  ]))
  identity_store_id = tolist(data.aws_ssoadmin_instances.sso[0].identity_store_ids)[0]
  alternate_identifier {
    unique_attribute {
      attribute_path  = "UserName"
      attribute_value = each.value
    }
  }
}

resource "aws_grafana_role_association" "role" {
  for_each = {
    for role in try(var.grafana.aws_sso, []) : role.role => role
    if try(var.grafana.create, false)
  }
  role         = each.value.role
  workspace_id = aws_grafana_workspace.this[0].id
  group_ids = [
    for group in try(each.value.groups, []) : data.aws_identitystore_group.group[group].id
  ]
  user_ids = [
    for user in try(each.value.users, []) : data.aws_identitystore_user.user[user].id
  ]
}