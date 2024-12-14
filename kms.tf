##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

module "kms" {
  count      = try(var.kms.create, false) ? 1 : 0
  source     = "github.com/cloudopsworks/terraform-module-aws-kms.git?ref=v1.0.0"
  is_hub     = var.is_hub
  org        = var.org
  spoke_def  = var.spoke_def
  extra_tags = var.extra_tags
  prefix     = "prometheus"
  config = {
    deletion_window_in_days = 30
    description             = "KMS key for AWS Prometheus Workspaces in ${var.org.organization_name} - ${var.org.environment_name}"
    enable_key_rotation     = try(var.kms.enable_key_rotation, false)
  }
}