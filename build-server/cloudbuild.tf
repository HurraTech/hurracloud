locals {
  projects = {
    "nginx-proxy" : {
      "dockerfile" : "Dockerfile",
      "context" : "nginx-proxy",
      "included_files" : ["nginx-proxy/**"]
    },
    "jawhar" : {
      "dockerfile" : "Jawhar.Dockerfile",
      "context" : ""
      "included_files" : ["jawhar/**"]
    },
    "samaa" : {
      "dockerfile" : "Samaa.Dockerfile",
      "context" : ""
      "base_stage" : "build"
      "included_files" : ["samaa/**"]
    },
    "app-runner" : {
      "dockerfile" : "AppRunner.Dockerfile",
      "context" : ""
      "included_files" : ["app-runner/**"]
    },
    "syncthing" : {
      "dockerfile" : "Dockerfile",
      "context" : "docker-syncthing"
      "included_files" : ["docker-syncthing/**"]
    }
  }
}

resource "google_cloudbuild_trigger" "hurra-build" {
  for_each = local.projects
  project  = "hurrabuild"
  name     = each.key
  trigger_template {
    branch_name = "^master$"
    repo_name   = "bitbucket_aimannajjar_hurracloud"
  }
  included_files = each.value.included_files
  ignored_files = [
    "**/*.md",
  ]
  substitutions = {
    _DOCKER_FILE = each.value.dockerfile
    _CONTEXT     = each.value.context
    _APP_NAME    = each.key
    _BASE_STAGE  = lookup(each.value, "base_stage", "")
  }

  filename = "cloudbuild/cloudbuild.yaml"
}
