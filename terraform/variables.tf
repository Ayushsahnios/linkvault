variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "linkvault"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "staging"
}

variable "db_connection_string" {
  description = "Neon Postgres connection string"
  type        = string
  sensitive   = true
}

variable "ecr_image_uri" {
  description = "Full ECR image URI including tag"
  type        = string
}
