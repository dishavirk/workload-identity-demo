# GCP Workload Identity and Terraform Setup

This repository contains the code and configuration needed to set up **Workload Identity** in **Google Kubernetes Engine (GKE)** using **Terraform**. 

It also demonstrates how to use **Google Service Accounts (GSA)**, bind them to **Kubernetes Service Accounts (KSA)**, and securely authenticate workloads running in Kubernetes without needing long-lived service account keys.

## Pre-requisites

- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)
- [Terraform](https://www.terraform.io/downloads.html)
- A GCP project with **billing enabled**.
- **Service account** with sufficient permissions to manage GCP resources.

## Project Overview

This repository covers:
1. Setting up a GKE cluster with **Workload Identity** enabled.
2. Binding **Kubernetes Service Accounts (KSA)** to **Google Service Accounts (GSA)**.
3. Storing **Terraform state** in a **Google Cloud Storage (GCS)** bucket for safe, remote state management.
4. Authenticating Terraform to GCP using a **Service Account JSON key**.

---

## Step 1: Create a GCS Bucket for Terraform State Storage

Terraform state is stored in a **Google Cloud Storage (GCS)** bucket for centralized and remote state management. 

My Project ID and GCS bucket name are `workload-identity-demo-2024`and `workload-identity-demo-2024-tf-state` respectively, please replace them with yours in the following commands.

1. Create the bucket using the following command:

    ```bash
    gsutil mb -p workload-identity-demo-2024 -l us-central1 gs://[your-bucket-name]
    ```

2. Enable versioning on the bucket (optional but recommended for rollback purposes):

    ```bash
    gsutil versioning set on gs://workload-identity-demo-2024-tf-state
    ```

The bucket name and configuration are specified in the `backend.tf` file, which looks like this:

```hcl
terraform {
  backend "gcs" {
    bucket  = "workload-identity-demo-2024-tf-state"
    prefix  = "terraform/state"
  }
}
```
## Step 2: Set up GSA for Terraform and GCP Authentication

Terraform requires a **Google Service Account (GSA)** to authenticate and manage GCP resources. This repository uses a service account JSON key for authentication.


1. **Create the GSA** for Terraform:

    ```bash
    gcloud iam service-accounts create terraform-sa \
      --display-name "Terraform Service Account"
    ```

2. **Assign IAM Roles** to the GSA:

    ```bash
    gcloud projects add-iam-policy-binding workload-identity-demo-2024 \
      --member "serviceAccount:terraform-sa@workload-identity-demo-2024.iam.gserviceaccount.com" \
      --role roles/editor

    gcloud projects add-iam-policy-binding workload-identity-demo-2024 \
      --member "serviceAccount:terraform-sa@workload-identity-demo-2024.iam.gserviceaccount.com" \
      --role roles/iam.serviceAccountUser
    ```

3. **Generate a key for the GSA** and save it locally:

    ```bash
    gcloud iam service-accounts keys create ~/path-to-your-key/terraform-sa-key.json \
      --iam-account terraform-sa@workload-identity-demo-2024.iam.gserviceaccount.com
    ```

4. **Configure Terraform** to use the **service account key** for authentication by specifying the file path in `main.tf`:

    ```hcl
    provider "google" {
      project     = var.project_id
      region      = var.region
      credentials = file("/Users/your-username/path-to-your-key/terraform-sa-key.json")
    }
    ```

This allows Terraform to authenticate to GCP using the service account key.
