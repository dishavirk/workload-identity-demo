
resource "google_container_cluster" "primary" {
  name     = "workload-identity-cluster"
  location = var.zone

  remove_default_node_pool = true
  initial_node_count       = 1
  deletion_protection      = false

  # Enable Workload Identity at the cluster level
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
}

resource "google_container_node_pool" "primary_nodes" {
  cluster    = google_container_cluster.primary.name
  location   = google_container_cluster.primary.location
  node_count = 2

  node_config {
    machine_type = "e2-small"
    disk_type    = "pd-standard"
    disk_size_gb = "20"
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]

    # Enable Workload Identity at the node level
    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}
