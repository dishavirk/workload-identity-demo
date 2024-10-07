terraform {
  backend "gcs" {
    bucket = "workload-identity-demo-2024-tf-state"
    prefix = "terraform/state"
  }
}
provider "google" {
  project     = var.project_id
  zone        = var.zone
  credentials = file("/Users/fuddook/tf-service-acc-key.json") # This should point to your service account key
}
