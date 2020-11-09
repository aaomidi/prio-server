variable "gcp_region" {
  type = string
}

variable "data_share_processor_gcp_sa_email" {
  type = string
}

variable "ingestion_bucket_name" {
  type = string
}

variable "ingestion_bucket_writer_gcp_sa_email" {
  type = string
}

variable "local_peer_validation_bucket_name" {
  type = string
}

variable "local_peer_validation_bucket_writer_gcp_sa_email" {
  type = string
}

# The ingestion bucket for this data share processor, to which ingestors write
# ingestion batches.
resource "google_storage_bucket" "ingestion_bucket" {
  provider                    = google-beta
  name                        = var.ingestion_bucket_name
  location                    = var.gcp_region
  force_destroy               = true
  uniform_bucket_level_access = true
}

# Permit the ingestion server to write to the ingestion bucket. It is assumed
# that the ingestion server advertises a GCP service account email.
resource "google_storage_bucket_iam_binding" "ingestion_bucket_writer" {
  bucket = google_storage_bucket.ingestion_bucket.name
  role   = "roles/storage.objectCreator"
  members = [
    "serviceAccount:${var.ingestion_bucket_writer_gcp_sa_email}"
  ]
}

# Permit our own data share processor's workflow manager and facilitators to
# read content from the ingestion bucket.
resource "google_storage_bucket_iam_binding" "ingestion_bucket_reader" {
  bucket = google_storage_bucket.ingestion_bucket.name
  role   = "roles/storage.objectViewer"
  members = [
    "serviceAccount:${var.data_share_processor_gcp_sa_email}"
  ]
}

# The peer validation bucket for this data share processor, to which peer data
# share processors write validation batches.
resource "google_storage_bucket" "local_peer_validation_bucket" {
  provider                    = google-beta
  name                        = var.local_peer_validation_bucket_name
  location                    = var.gcp_region
  force_destroy               = true
  uniform_bucket_level_access = true
}

# Permit the peer data share processors to write to the ingestion bucket. It is
# assumed that all peer DSPs will impersonate a single GCP SA whose email is
# advertised from the peer DSP global manifest.
resource "google_storage_bucket_iam_binding" "local_peer_validation_bucket_writer" {
  bucket = google_storage_bucket.local_peer_validation_bucket.name
  role   = "roles/storage.objectCreator"
  members = [
    "serviceAccount:${var.local_peer_validation_bucket_writer_gcp_sa_email}"
  ]
}

# Permit our own data share processor's workflow manager and facilitators to
# read content from the peer validation bucket.
resource "google_storage_bucket_iam_binding" "local_peer_validation_bucket_reader" {
  bucket = google_storage_bucket.local_peer_validation_bucket.name
  role   = "roles/storage.objectViewer"
  members = [
    "serviceAccount:${var.data_share_processor_gcp_sa_email}"
  ]
}
