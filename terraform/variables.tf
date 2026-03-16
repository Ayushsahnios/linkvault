variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Project name used for tagging and naming resources"
  type        = string
  default     = "linkvault"
}

variable "environment" {
  description = "Environment name (staging or production)"
  type        = string
  default     = "staging"
}

variable "db_username" {
  description = "Postgres database username"
  type        = string
  default     = "linkvault"
  sensitive   = true
}

variable "db_password" {
  description = "Postgres database password"
  type        = string
  sensitive   = true
}

variable "ecr_image_uri" {
  description = "Full ECR image URI including tag"
  type        = string
}
