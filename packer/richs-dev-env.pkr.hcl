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
  pull   = true
  commit = true
}

# Build
build {
  name = "richs-dev-env"
  sources = [
    "source.docker.dev-env"
  ]

  # PROVISIONERS #

  # Update APK package manager & install core system packages
  provisioner "shell" {
    inline = [
      "apk update",
      "apk upgrade",
      "apk add --no-cache bash zsh ca-certificates gnupg openssl curl tar openssh-client sshpass git shadow packer"
    ]
  }

  # Setup Python 3
  provisioner "shell" {
    environment_vars = [
      "PYTHON3_VERSION=${var.python3_version}"
    ]
    script = "./python3/install_python3.sh"
  }

  # Setup Ansible
  provisioner "shell" {
    environment_vars = [
      "ANSIBLE_VERSION=${var.ansible_version}",
    ]
    script = "./ansible/install_ansible.sh"
  }

  # Create step-down user
  provisioner "shell" {
    inline = [
      "adduser -D -s /bin/zsh -g \"Cayde 6\" cayde",
      "sh -c \"$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\" \"\" --unattended"
    ]
  }

  # Now use Ansible to setup the rest of the image
  provisioner "ansible-local" {
    playbook_file   = "./ansible/playbooks/richs-dev-environment.yaml"
    extra_arguments = ["--extra-vars", "\"target=localhost\""]
  }

  # Clearing out package caches
  provisioner "shell" {
    inline = [
      "apk del build-dependencies",
      "rm -rf /var/cache/apk/*",
      "rm -rf /root/.cache/pip/*"
    ]
  }

  # POST PROCESSORS #
  post-processors {
    post-processor "docker-tag" {
      repository = "n0sn1b0r/richs-dev-env"
      tags       = ["latest"]
      force      = true
    }

    // post-processor "docker-push" {
    //   login = true
    // }
  }
}
