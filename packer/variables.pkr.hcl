# Variables
variable "docker_image" {
  type        = string
  description = "The base Docker image to start from"
  default     = "alpine:3"
}

variable "ansible_version" {
  type        = string
  description = "Version of Ansible to install"
  default     = "latest"
}

variable "docker_ce_version" {
  type        = string
  description = "Version of Docker CE to install"
  default     = "latest"
}
