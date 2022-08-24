# variables.pkr.hcl files are used to define variables which are settable at runtime.
# This includes descriptions and suitable defaults for the case when the user doesn't specify a variable's value at runtime.

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

variable "python3_version" {
  type        = string
  description = "Version of Python 3"
  default     = "latest"
}

variable "runtime_username" {
  type        = string
  description = "The username for the step-down user of the container"
  default     = "cayde"
}
