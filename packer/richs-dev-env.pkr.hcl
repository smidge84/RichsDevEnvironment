packer {
  required_plugins {
    docker = {
      version = ">= 0.0.7"
      source  = "github.com/hashicorp/docker"
    }
  }
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
    inline = [
      "echo Running ${var.docker_image} Docker image."
    ]
  }

  provisioner "shell" {
    inline = [
      "apk update",
      "apk add --no-cache bash"
    ]
  }

  provisioner "shell" {
    environment_vars = [
      "ANSIBLE_VERSION=${var.ansible_version}",
      "DOCKER_SDK_VERSION=${var.docker_sdk_python_version}"
    ]
    script = "./ansible/install_ansible.sh"
  }

  # Post Processors
  post-processor "docker-tag" {
    repository = "n0sn1b0r/richs-dev-env"
    tags       = ["latest"]
    force      = true
  }
}
