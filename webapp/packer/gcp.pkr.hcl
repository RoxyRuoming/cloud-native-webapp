packer {
  required_plugins {
    googlecompute = {
      source  = "github.com/hashicorp/googlecompute"
      version = ">=1.1.0, <2.0.0"
    }
  }
}

source "googlecompute" "webapp-custom-image" {
  project_id   = var.project_id
  zone         = var.zone
  ssh_username = var.ssh_username
  network      = "projects/${var.project_id}/global/networks/default"

  source_image            = var.source_image
  source_image_family     = var.source_image_family
  image_name              = var.image_name
  image_description       = "Custom image for csye6225-webapp"
  image_family            = var.image_family
  image_project_id        = var.project_id
  image_storage_locations = ["us"]

  disk_type = var.disk_type
  disk_size = var.disk_size
}

variable "project_id" {
  type    = string
  default = "csye6225-dev-a04"
}

variable "zone" {
  type    = string
  default = "us-east1-b"
}

variable "ssh_username" {
  type    = string
  default = "packer"
}

variable "source_image" {
  type    = string
  default = ""
}

variable "source_image_family" {
  type    = string
  default = "centos-stream-8"
}

variable "image_name" {
  type    = string
  default = "csye6225-{{timestamp}}"
}

variable "image_family" {
  type    = string
  default = "csye6225-{{timestamp}}"
}

variable "disk_type" {
  type    = string
  default = "pd-standard"
}

variable "disk_size" {
  type    = string
  default = 20
}

build {
  sources = [
    "source.googlecompute.webapp-custom-image"
  ]

  // update the os
  provisioner "shell" {
    script = "scripts/updateOs.sh"
  }

  // make the app directory
  provisioner "shell" {
    script = "scripts/appDirSetup.sh"
  }

  // create user
  provisioner "shell" {
    script = "scripts/createUser.sh"
  }

  // copy the jar to the image using provisioner
  provisioner "file" {
    source      = "artifact/healthcheck-0.0.1-SNAPSHOT.jar"
    destination = "/opt/myapp/healthcheck-0.0.1-SNAPSHOT.jar"
  }

  provisioner "file" {
    source      = "webapp.service"
    destination = "/opt/myapp/webapp.service"
  }

  provisioner "file" {
    source      = "config.yaml"
    destination = "/opt/myapp/config.yaml"
  }

  // install ops agent
  provisioner "shell" {
    script = "scripts/installOpsAgent.sh"
  }

  // set up the tools before running the app
  provisioner "shell" {
    script = "scripts/setupTools.sh"
  }

  // enable the service (systemD)
  provisioner "shell" {
    script = "scripts/enableService.sh"
  }
}

