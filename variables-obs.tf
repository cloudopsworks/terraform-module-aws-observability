##
# (c) 2021-2026
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

variable "prometheus" {
  description = <<-EOT
    Prometheus Workspace & Scrapers configurations. Each key defines a logical workspace.
    Structure:
      [workspace_key]:
        name: "my-workspace"         # (Optional) Full workspace alias. Overrides name_prefix.
        name_prefix: "myapp"         # (Optional) Prefix for auto-generated alias. Required if name not set.
        logging:
          create_log_group: true     # (Optional) Create a CloudWatch Log Group. Default: false.
          retention_in_days: 7       # (Optional) Log retention in days. Default: 7.
          log_group_class: "STANDARD"  # (Optional) Log group class. Values: STANDARD, INFREQUENT_ACCESS. Default: "STANDARD".
          log_group_arn: "arn:..."   # (Optional) Existing CloudWatch log group ARN. Used if create_log_group is false.
        scrapers:
          [scraper_key]:
            name: "my-scraper"       # (Optional) Full scraper alias. Overrides name_prefix.
            name_prefix: "myapp"     # (Optional) Prefix for auto-generated scraper alias. Required if name not set.
            config: "..."            # (Optional) Custom Prometheus scrape configuration YAML. Uses AWS default scraper config if omitted.
  EOT
  type        = any
  default     = {}
}

variable "grafana" {
  description = <<-EOT
    Grafana Workspace & Dashboards configurations.
    Structure:
      create: true                              # (Required) Whether to create the Grafana workspace. Default: false.
      name: "my-grafana"                        # (Optional) Full workspace name. Overrides name_prefix.
      name_prefix: "myapp"                      # (Optional) Prefix for auto-generated name. Required if name not set.
      account_access_type: "CURRENT_ACCOUNT"   # (Optional) Account access type. Values: CURRENT_ACCOUNT, ORGANIZATION. Default: "CURRENT_ACCOUNT".
      authentication_providers: ["AWS_SSO"]    # (Optional) List of authentication providers. Values: AWS_SSO, SAML.
      permission_type: "SERVICE_MANAGED"       # (Optional) Permission type. Values: SERVICE_MANAGED, CUSTOMER_MANAGED. Default: "SERVICE_MANAGED".
      configuration: {}                         # (Optional) Grafana workspace configuration object. JSON-encoded internally.
      data_sources: ["PROMETHEUS"]             # (Optional) Data source types to enable. Values: PROMETHEUS, CLOUDWATCH, XRAY, TIMESTREAM, SITEWISE, ATHENA, REDSHIFT.
      notification_destinations: ["SNS"]       # (Optional) Notification destinations. Values: SNS.
      organization_role_name: "..."            # (Optional) AWS Organizations role name for cross-account access.
      organizational_units: ["ou-..."]         # (Optional) List of organizational unit IDs to grant workspace access.
      grafana_version: "10.4"                  # (Optional) Grafana version to deploy. Uses AWS-managed default if omitted.
      description: "..."                        # (Optional) Workspace description. Auto-generated from name if omitted.
      aws_sso:                                  # (Optional) List of AWS SSO role mappings for workspace access control.
        - role: "ADMIN"                         # (Required) Grafana workspace role. Values: ADMIN, EDITOR, VIEWER.
          groups: ["DevOps-Admins"]             # (Optional) List of AWS SSO group display names to assign the role.
          users: ["user@example.com"]          # (Optional) List of AWS SSO usernames to assign the role.
  EOT
  type        = any
  default     = {}
}

variable "eks" {
  description = <<-EOT
    EKS Cluster configurations for Prometheus scraper source.
    Structure:
      name: "my-cluster"              # (Optional) EKS cluster name for data source lookup. Automatically resolves cluster_arn, subnet_ids, and security_group_ids.
      cluster_arn: "arn:aws:..."      # (Optional) EKS cluster ARN. Required if name is not provided.
      cluster_name: "my-cluster"      # (Optional) Cluster name used for resource tagging. Required if name is not provided.
      subnet_ids: ["subnet-..."]      # (Optional) List of VPC subnet IDs for the scraper. Required if name is not provided.
      security_group_ids: ["sg-..."]  # (Optional) List of security group IDs for the scraper. Required if name is not provided.
  EOT
  type        = any
  default     = {}
}

variable "vpc" {
  description = <<-EOT
    VPC configurations for Grafana workspace network isolation.
    Structure:
      vpc_id: "vpc-..."                     # (Optional) VPC ID. Required when create_security_group is true.
      subnet_ids: ["subnet-..."]            # (Optional) List of subnet IDs for the Grafana workspace VPC configuration.
      security_group_ids: ["sg-..."]        # (Optional) List of existing security group IDs to attach to the Grafana workspace.
      create_security_group: false          # (Optional) Whether to create a dedicated security group for Grafana. Default: false.
  EOT
  type        = any
  default     = {}
}

variable "kms" {
  description = <<-EOT
    KMS Key configurations for encryption at rest.
    Structure:
      create: false                         # (Optional) Whether to create a KMS key for encrypting Prometheus workspaces and CloudWatch logs. Default: false.
      enable_key_rotation: false            # (Optional) Whether to enable automatic KMS key rotation. Default: false.
      rotation_period_in_days: 90           # (Optional) KMS key rotation period in days. Valid range: 90–2560. Default: 90.
  EOT
  type        = any
  default     = {}
}
