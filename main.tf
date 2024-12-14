##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

locals {
  alias_names = {
    for k, v in var.prometheus : k => {
      plain     = try(v.name, "") != "" ? v.name : format("%s-%s", v.name_prefix, local.system_name)
      workspace = try(v.name, "") != "" ? v.name : format("%s-%s-workspace", v.name_prefix, local.system_name)
    }
  }
}

resource "aws_cloudwatch_log_group" "this" {
  for_each = {
    for k, v in var.prometheus : k => v
    if try(v.logging.create_log_group, false)
  }
  name              = format("/aws/prometheus/%s", local.alias_names[each.key].plain)
  retention_in_days = try(each.value.logging.retention_in_days, 7)
  log_group_class   = try(each.value.logging.log_group_class, "STANDARD")
  kms_key_id        = try(var.prometheus.kms.create, false) ? module.kms.kms_key_id : null
  tags              = local.all_tags
}

resource "aws_prometheus_workspace" "this" {
  for_each = var.prometheus
  alias    = local.alias_names[each.key].workspace
  dynamic "logging_configuration" {
    for_each = length(try(each.value.logging, {})) > 0 ? [1] : []
    content {
      log_group_arn = "${try(each.value.logging.create_log_group, false) ? aws_cloudwatch_log_group.this[each.key].arn : each.value.logging.log_group_arn}:*"
    }
  }
  kms_key_arn = try(var.prometheus.kms.create, false) ? module.kms.kms_key_arn : null
  tags        = local.all_tags
}

data "aws_eks_cluster" "this" {
  count = try(var.eks.name, "") != "" ? 1 : 0
  name  = var.eks.name
}

data "aws_prometheus_default_scraper_configuration" "sample" {}

resource "aws_prometheus_scraper" "this" {
  for_each = merge([
    for k, v in var.prometheus : {
      for s, conf in v.scrapers : format("%s-%s", k, s) => {
        prom          = k
        scraper_alias = try(conf.name, "") != "" ? conf.name : format("%s-%s-scraper", conf.name_prefix, local.system_name)
        config        = try(conf.config, "")
      }
    }
  ]...)
  alias = each.value.scraper_alias
  source {
    eks {
      cluster_arn        = try(var.eks.name, "") != "" ? data.aws_eks_cluster.this[0].arn : var.eks.cluster_arn
      subnet_ids         = try(var.eks.name, "") != "" ? data.aws_eks_cluster.this[0].vpc_config[0].subnet_ids : var.eks.subnet_ids
      security_group_ids = try(var.eks.name, "") != "" ? data.aws_eks_cluster.this[0].vpc_config[0].security_group_ids : var.eks.security_group_ids
    }
  }
  destination {
    amp {
      workspace_arn = aws_prometheus_workspace.this[each.value.prom].arn
    }
  }
  scrape_configuration = each.value.config != "" ? each.value.config : data.aws_prometheus_default_scraper_configuration.sample.configuration
  tags = merge(local.all_tags,
    {
      "eks-cluster-name" = try(var.eks.name, "") != "" ? data.aws_eks_cluster.this[0].name : var.eks.cluster_name
  })
}