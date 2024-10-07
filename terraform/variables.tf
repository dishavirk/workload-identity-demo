
variable "project_id" {
  description = "The GCP project ID"
  type        = string
  default     = "workload-identity-demo-2024"
}

variable "zone" {
  description = "GCP region for the cluster"
  type        = string
  default     = "us-central1-b"
}