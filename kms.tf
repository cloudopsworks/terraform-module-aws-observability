##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

module "kms" {
  count      = try(var.kms.create, false) ? 1 : 0
  source     = "github.com/cloudopsworks/terraform-module-aws-kms.git?ref=v1.0.1"
  is_hub     = var.is_hub
  org        = var.org
  spoke_def  = var.spoke_def
  extra_tags = var.extra_tags
  prefix     = "prometheus"
  config = {
    deletion_window_in_days = 30
    description             = "KMS key for AWS Prometheus Workspaces in ${var.org.organization_name} - ${var.org.environment_name}"
    enable_key_rotation     = try(var.kms.enable_key_rotation, false)
    rotation_period_in_days = try(var.kms.rotation_period_in_days, 90)
    statements = [
      {
        sid    = "CloudWatchLogs"
        effect = "Allow"
        actions = [
          "kms:Encrypt*",
          "kms:Decrypt*",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*"
        ]
        resources = ["*"]

        principals = [
          {
            type        = "Service"
            identifiers = ["logs.${data.aws_region.current.name}.amazonaws.com"]
          }
        ]

        conditions = [
          {
            test     = "ArnLike"
            variable = "kms:EncryptionContext:aws:logs:arn"
            values = [
              "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/prometheus/*",
            ]
          }
        ]
      },
      {
        sid    = "AWSPrometheus"
        effect = "Allow"
        actions = [
          "kms:DescribeKey",
          "kms:CreateGrant",
          "kms:GenerateDataKey",
          "kms:Decrypt"
        ]
        principals = [
          {
            type        = "AWS"
            identifiers = ["*"]
          }
        ]
        resources = ["*"]
        conditions = [
          {
            test     = "StringEquals"
            variable = "kms:ViaService"
            values   = ["aps.${data.aws_region.current.name}.amazonaws.com"]
          },
          {
            test     = "StringEquals"
            variable = "kms:CallerAccount"
            values   = [data.aws_caller_identity.current.account_id]
          }
        ]
      }
    ]
  }
}