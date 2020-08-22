locals {
  projects = {
    "nginx-proxy" : {
      "dockerfile" : "Dockerfile",
      "context" : "nginx-proxy"
    },
    "jawhar" : {
      "dockerfile" : "Jawhar.Dockerfile",
      "context" : ""
    },
    "samaa" : {
      "dockerfile" : "Samaa.Dockerfile",
      "context" : ""
      "base_stage" : "build"
    },
    "app-runner" : {
      "dockerfile" : "AppRunner.Dockerfile",
      "context" : ""
    },
    "syncthing" : {
      "dockerfile" : "Dockerfile",
      "context" : "docker-syncthing"
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

  substitutions = {
    _DOCKER_FILE = each.value.dockerfile
    _CONTEXT     = each.value.context
    _APP_NAME    = each.key
    _BASE_STAGE  = lookup(each.value, "base_stage" , "")
  }

  filename = "cloudbuild/cloudbuild.yaml"
}
