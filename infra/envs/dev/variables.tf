variable "aws_region" {
  description = "AWS region for all docintel resources."
  type        = string
  default     = "us-east-1"
}

variable "alert_email" {
  description = "Email address that receives budget alerts. Set in terraform.tfvars (gitignored) or TF_VAR_alert_email."
  type        = string
  sensitive   = true
}

variable "monthly_budget_usd" {
  description = "Monthly AWS cost budget in USD."
  type        = string
  default     = "15.0"
}
