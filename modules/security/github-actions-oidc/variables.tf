variable "role_name_prefix" {
  description = "Prefix for the IAM role name"
  type        = string
  default     = "github-actions"
}

variable "allowed_repositories" {
  description = "List of GitHub repositories allowed to assume this role"
  type = list(object({
    org    = string
    repo   = string
    branch = string
  }))
}

variable "enable_terraform_backend_access" {
  description = "Enable permissions for Terraform S3 backend"
  type        = bool
  default     = false
}

variable "terraform_state_bucket" {
  description = "S3 bucket for Terraform state (required if enable_terraform_backend_access is true)"
  type        = string
  default     = ""
}

variable "terraform_lock_table" {
  description = "DynamoDB table for Terraform state locking (required if enable_terraform_backend_access is true)"
  type        = string
  default     = ""
}

variable "custom_policy_json" {
  description = "Custom IAM policy JSON for additional permissions"
  type        = string
  default     = ""
}

variable "managed_policy_arns" {
  description = "List of AWS managed policy ARNs to attach"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
