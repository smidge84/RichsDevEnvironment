packer {
  required_plugins {
    docker = {
      version = ">= 0.0.7"
      source  = "github.com/hashicorp/docker"
    }
  }
}

# Variables
variable "docker_image" {
  type        = string
  description = "The base Docker image to start from"
  default     = "alpine:3"
}

# Sources
source "docker" "container" {
  image  = var.docker_image
  commit = true
}

# Build
build {
  name = "learn-packer"
  sources = [
    "source.docker.container"
  ]

  # Provisioners
  provisioner "shell" {
    inline = ["echo Running ${var.docker_image} Docker image."]
  }

  # Post Processors
  post-processor "docker-tag" {
    repository = "n0sn1b0r/richs-dev-env"
    tags       = ["latest"]
    force      = true
  }
}
