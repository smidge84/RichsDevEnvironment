packer {
  required_plugins {
    docker = {
      version = ">= 0.0.7"
      source  = "github.com/hashicorp/docker"
    }
  }
}

# Sources
source "docker" "dev-env" {
  image  = var.docker_image
  commit = true
}

# Build
build {
  name = "richs-dev-env"
  sources = [
    "source.docker.dev-env"
  ]

  # Provisioners

  # Update APK package manager & install core system packages
  provisioner "shell" {
    inline = [
      "apk update",
      "apk add --no-cache bash ca-certificates openssl curl tar openssh-client sshpass git"
    ]
  }

  provisioner "shell" {
    environment_vars = [
      "PYTHON3_VERSION=${var.python3_version}"
    ]
    script = "./python3/install_python3.sh"
  }

  provisioner "shell" {
    environment_vars = [
      "ANSIBLE_VERSION=${var.ansible_version}",
      "DOCKER_SDK_VERSION=${var.docker_sdk_python_version}"
    ]
    script = "./ansible/install_ansible.sh"
  }

  # Clearing out package caches
  provisioner "shell" {
    inline = [
      "rm -rf /var/cache/apk/*",
      "rm -rf /root/.cache/pip/*"
    ]
  }

  # Post Processors
  post-processor "docker-tag" {
    repository = "n0sn1b0r/richs-dev-env"
    tags       = ["latest"]
    force      = true
  }
}
