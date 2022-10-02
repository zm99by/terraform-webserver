# Specify the GCP Provider
provider "google" {
  credentials = file("~/Downloads/svc.json")
  project = var.project_id
  region  = var.region
}