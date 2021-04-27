variable "region" {
  default = "eu-west-2"
}

variable "stage" {
  default = "dev"
}

variable "prefix" {
  default = "healthcarelake"

  validation {
    condition     = can(regex("^[-a-z0-9]+$", var.prefix))
    error_message = "The prefix must be all lowercase letters."
  }
}

variable "username" {
  default = null
}

variable "password" {
  default = null
}