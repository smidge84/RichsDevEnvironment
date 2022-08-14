# Variables
variable "docker_image" {
  type        = string
  description = "The base Docker image to start from"
  default     = "alpine:3"
}

variable "ansible_version" {
  type        = string
  description = "Version of Ansible"
  default     = "latest"
}

variable "docker_sdk_python_version" {
  type        = string
  description = "Version of Docker SDK for Python"
  default     = "latest"
}

variable "docker_ce_version" {
  type        = string
  description = "Version of Docker CE"
  default     = "latest"
}
