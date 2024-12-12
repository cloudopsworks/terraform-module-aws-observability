##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

variable "prometheus" {
  description = "Prometheus Workspace & Scrappers configurations"
  type        = any
  default     = {}
}

variable "grafana" {
  description = "Grafana Workspace & Dashboards configurations"
  type        = any
  default     = {}
}

variable "eks" {
  description = "EKS Cluster configurations"
  type        = any
  default     = {}
}

variable "vpc" {
  description = "VPC configurations"
  type        = any
  default     = {}
}