variable "project_id" {
  description = "Your GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region to deploy into"
  type        = string
  default     = "us-east1"
}

variable "zone" {
  description = "GCP zone to deploy into"
  type        = string
  default     = "us-east1-b"
}

variable "machine_type" {
  description = "VM size. Jenkins+Nexus+Tomcat together are memory-hungry — don't go smaller than e2-standard-2."
  type        = string
  default     = "n2-standard-2"
}

variable "admin_ip" {
  description = "Your own public IP (as CIDR, e.g. 203.0.113.5/32), allowed full admin access to Jenkins/Nexus/Tomcat UIs. Find yours at https://whatismyip.com"
  type        = string
}

variable "repo_url" {
  description = "Git repo URL the VM will clone on startup"
  type        = string
}