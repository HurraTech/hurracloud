provider "google" {}

resource "google_compute_instance" "hurra-build" {
  boot_disk {
    auto_delete = "false"
    device_name = "hurra-build"

    initialize_params {
      image = "ubuntu-2004-focal-v20200810"
      size  = "200"
      type  = "pd-ssd"
    }

    mode = "READ_WRITE"
  }

  machine_type = "c2-standard-8"


  metadata = {
    bitbucket-key = file("~/.ssh/bitbucket")
    user-data     = file("${path.module}/build-user-data.yaml")
  }

  name = "hurra-build"

  network_interface {
    network            = "default"
    subnetwork_project = "hurrabuild"
    access_config {
      network_tier = "PREMIUM"
    }
  }

  project = "hurrabuild"

  scheduling {
    automatic_restart   = "false"
    on_host_maintenance = "TERMINATE"
    preemptible         = "true"
  }

  service_account {
    email = "356836837404-compute@developer.gserviceaccount.com"
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  shielded_instance_config {
    enable_integrity_monitoring = "true"
    enable_secure_boot          = "false"
    enable_vtpm                 = "true"
  }

  zone = "us-east1-b"
}

resource "google_storage_bucket" "hurrabuild-build" {
  bucket_policy_only       = "false"
  default_event_based_hold = "false"
  force_destroy            = "false"
  location                 = "us-east1"
  name                     = "hurrabuild-build"
  project                  = "hurrabuild"
  requester_pays           = "false"
  storage_class            = "STANDARD"
}

# resource "google_storage_bucket_acl" "hurrabuild-build" {
#   bucket = "hurrabuild-build"
# }
#
#
# resource "google_storage_bucket_iam_policy" "hurrabuild-build" {
#   bucket = "b/hurrabuild-build"
#
#   policy_data = <<POLICY
# {
#   "bindings": [
#     {
#       "members": [
#         "projectEditor:hurrabuild",
#         "projectOwner:hurrabuild"
#       ],
#       "role": "roles/storage.legacyBucketOwner"
#     },
#     {
#       "members": [
#         "projectViewer:hurrabuild"
#       ],
#       "role": "roles/storage.legacyBucketReader"
#     }
#   ]
# }
# POLICY
# }
#
# resource "google_storage_default_object_acl" "hurrabuild-build" {
#   bucket      = "hurrabuild-build"
#   role_entity = ["OWNER:project-editors-356836837404", "OWNER:project-owners-356836837404", "READER:project-viewers-356836837404"]
# }
