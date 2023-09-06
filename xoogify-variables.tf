variable portfolio_id {
  type = string
  description = "The ID of the portfolio to which to associate the principal."
}

variable "project_id" {
  type = string
}

################################################################################
# GitHub OIDC Role
################################################################################

variable "xoogify_name" {
  description = "Name of IAM role"
  type        = string
  default     = "xoogify-oidc-hyperautomation"
}

variable "xoogify_path" {
  description = "Path of IAM role"
  type        = string
  default     = "/"
}

variable "xoogify_permissions_boundary_arn" {
  description = "Permissions boundary ARN to use for IAM role"
  type        = string
  default     = null
}

variable "xoogify_description" {
  description = "IAM Role description"
  type        = string
  default     = "Role used by hypetautomation"
}

variable "xoogify_name_prefix" {
  description = "IAM role name prefix"
  type        = string
  default     = null
}

variable "xoogify_force_detach_policies" {
  description = "Whether policies should be detached from this role when destroying"
  type        = bool
  default     = true
}

variable "xoogify_max_session_duration" {
  description = "Maximum CLI/API session duration in seconds between 3600 and 43200"
  type        = number
  default     = null
}

variable "xoogify_organizations" {
  description = "List of xoogify organizations that are allowed to assume xoofigy hyperautomation role"
  type        = list(string)
  default     = []
}

variable "xoogify_uids" {
  description = "List of xoogify user ids that are allowed to assume xoofigy hyperautomation role"
  type        = list(string)
  default     = []
}

variable "xoogify_architectures" {
  description = "List of xoogify architectures that are allowed to assume xoofigy hyperautomation role"
  type        = list(string)
  default     = []
}