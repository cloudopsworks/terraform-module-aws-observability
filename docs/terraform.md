## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.4 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 6.4 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_kms"></a> [kms](#module\_kms) | github.com/cloudopsworks/terraform-module-aws-kms.git | v1.0.1 |
| <a name="module_tags"></a> [tags](#module\_tags) | cloudopsworks/tags/local | 1.0.9 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_grafana_role_association.role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/grafana_role_association) | resource |
| [aws_grafana_workspace.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/grafana_workspace) | resource |
| [aws_iam_role.grafana](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.grafana](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.grafana_cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.grafana_xray](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_prometheus_scraper.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/prometheus_scraper) | resource |
| [aws_prometheus_workspace.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/prometheus_workspace) | resource |
| [aws_security_group.grafana](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_eks_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_iam_policy_document.grafana](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.grafana_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_identitystore_group.group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/identitystore_group) | data source |
| [aws_identitystore_user.user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/identitystore_user) | data source |
| [aws_prometheus_default_scraper_configuration.sample](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/prometheus_default_scraper_configuration) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_ssoadmin_instances.sso](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssoadmin_instances) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_eks"></a> [eks](#input\_eks) | EKS Cluster configurations for Prometheus scraper source.<br/>Structure:<br/>  name: "my-cluster"              # (Optional) EKS cluster name for data source lookup. Automatically resolves cluster\_arn, subnet\_ids, and security\_group\_ids.<br/>  cluster\_arn: "arn:aws:..."      # (Optional) EKS cluster ARN. Required if name is not provided.<br/>  cluster\_name: "my-cluster"      # (Optional) Cluster name used for resource tagging. Required if name is not provided.<br/>  subnet\_ids: ["subnet-..."]      # (Optional) List of VPC subnet IDs for the scraper. Required if name is not provided.<br/>  security\_group\_ids: ["sg-..."]  # (Optional) List of security group IDs for the scraper. Required if name is not provided. | `any` | `{}` | no |
| <a name="input_extra_tags"></a> [extra\_tags](#input\_extra\_tags) | n/a | `map(string)` | `{}` | no |
| <a name="input_grafana"></a> [grafana](#input\_grafana) | Grafana Workspace & Dashboards configurations.<br/>Structure:<br/>  create: true                              # (Required) Whether to create the Grafana workspace. Default: false.<br/>  name: "my-grafana"                        # (Optional) Full workspace name. Overrides name\_prefix.<br/>  name\_prefix: "myapp"                      # (Optional) Prefix for auto-generated name. Required if name not set.<br/>  account\_access\_type: "CURRENT\_ACCOUNT"   # (Optional) Account access type. Values: CURRENT\_ACCOUNT, ORGANIZATION. Default: "CURRENT\_ACCOUNT".<br/>  authentication\_providers: ["AWS\_SSO"]    # (Optional) List of authentication providers. Values: AWS\_SSO, SAML.<br/>  permission\_type: "SERVICE\_MANAGED"       # (Optional) Permission type. Values: SERVICE\_MANAGED, CUSTOMER\_MANAGED. Default: "SERVICE\_MANAGED".<br/>  configuration: {}                         # (Optional) Grafana workspace configuration object. JSON-encoded internally.<br/>  data\_sources: ["PROMETHEUS"]             # (Optional) Data source types to enable. Values: PROMETHEUS, CLOUDWATCH, XRAY, TIMESTREAM, SITEWISE, ATHENA, REDSHIFT.<br/>  notification\_destinations: ["SNS"]       # (Optional) Notification destinations. Values: SNS.<br/>  organization\_role\_name: "..."            # (Optional) AWS Organizations role name for cross-account access.<br/>  organizational\_units: ["ou-..."]         # (Optional) List of organizational unit IDs to grant workspace access.<br/>  grafana\_version: "10.4"                  # (Optional) Grafana version to deploy. Uses AWS-managed default if omitted.<br/>  description: "..."                        # (Optional) Workspace description. Auto-generated from name if omitted.<br/>  aws\_sso:                                  # (Optional) List of AWS SSO role mappings for workspace access control.<br/>    - role: "ADMIN"                         # (Required) Grafana workspace role. Values: ADMIN, EDITOR, VIEWER.<br/>      groups: ["DevOps-Admins"]             # (Optional) List of AWS SSO group display names to assign the role.<br/>      users: ["user@example.com"]          # (Optional) List of AWS SSO usernames to assign the role. | `any` | `{}` | no |
| <a name="input_is_hub"></a> [is\_hub](#input\_is\_hub) | Establish this is a HUB or spoke configuration | `bool` | `false` | no |
| <a name="input_kms"></a> [kms](#input\_kms) | KMS Key configurations for encryption at rest.<br/>Structure:<br/>  create: false                         # (Optional) Whether to create a KMS key for encrypting Prometheus workspaces and CloudWatch logs. Default: false.<br/>  enable\_key\_rotation: false            # (Optional) Whether to enable automatic KMS key rotation. Default: false.<br/>  rotation\_period\_in\_days: 90           # (Optional) KMS key rotation period in days. Valid range: 90–2560. Default: 90. | `any` | `{}` | no |
| <a name="input_org"></a> [org](#input\_org) | n/a | <pre>object({<br/>    organization_name = string<br/>    organization_unit = string<br/>    environment_type  = string<br/>    environment_name  = string<br/>  })</pre> | n/a | yes |
| <a name="input_prometheus"></a> [prometheus](#input\_prometheus) | Prometheus Workspace & Scrapers configurations. Each key defines a logical workspace.<br/>Structure:<br/>  [workspace\_key]:<br/>    name: "my-workspace"         # (Optional) Full workspace alias. Overrides name\_prefix.<br/>    name\_prefix: "myapp"         # (Optional) Prefix for auto-generated alias. Required if name not set.<br/>    logging:<br/>      create\_log\_group: true     # (Optional) Create a CloudWatch Log Group. Default: false.<br/>      retention\_in\_days: 7       # (Optional) Log retention in days. Default: 7.<br/>      log\_group\_class: "STANDARD"  # (Optional) Log group class. Values: STANDARD, INFREQUENT\_ACCESS. Default: "STANDARD".<br/>      log\_group\_arn: "arn:..."   # (Optional) Existing CloudWatch log group ARN. Used if create\_log\_group is false.<br/>    scrapers:<br/>      [scraper\_key]:<br/>        name: "my-scraper"       # (Optional) Full scraper alias. Overrides name\_prefix.<br/>        name\_prefix: "myapp"     # (Optional) Prefix for auto-generated scraper alias. Required if name not set.<br/>        config: "..."            # (Optional) Custom Prometheus scrape configuration YAML. Uses AWS default scraper config if omitted. | `any` | `{}` | no |
| <a name="input_spoke_def"></a> [spoke\_def](#input\_spoke\_def) | n/a | `string` | `"001"` | no |
| <a name="input_vpc"></a> [vpc](#input\_vpc) | VPC configurations for Grafana workspace network isolation.<br/>Structure:<br/>  vpc\_id: "vpc-..."                     # (Optional) VPC ID. Required when create\_security\_group is true.<br/>  subnet\_ids: ["subnet-..."]            # (Optional) List of subnet IDs for the Grafana workspace VPC configuration.<br/>  security\_group\_ids: ["sg-..."]        # (Optional) List of existing security group IDs to attach to the Grafana workspace.<br/>  create\_security\_group: false          # (Optional) Whether to create a dedicated security group for Grafana. Default: false. | `any` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_grafana_arn"></a> [grafana\_arn](#output\_grafana\_arn) | n/a |
| <a name="output_grafana_endpoint"></a> [grafana\_endpoint](#output\_grafana\_endpoint) | n/a |
| <a name="output_grafana_name"></a> [grafana\_name](#output\_grafana\_name) | n/a |
| <a name="output_grafana_version"></a> [grafana\_version](#output\_grafana\_version) | n/a |
| <a name="output_prometheus"></a> [prometheus](#output\_prometheus) | n/a |
| <a name="output_scrapers"></a> [scrapers](#output\_scrapers) | n/a |
