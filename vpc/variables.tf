variable "region" {
  type        = string
  description = "AWS Region"
}

variable "vpc_cidr_block" {
  type        = string
  description = "VPC CIDR block"
}

variable "vpc_tag_Name" {
  type        = string
  description = "VPC tag Name"
}

variable "subnet" {
  type        = map
  description = "Subnets properties"
}

variable "key_name" {
  type        = string
  description = "Key Name"
}

variable "allow_ssh_from" {
  type        = string
  description = "Allow SSH from this range"
  default     = "0.0.0.0/0"
}
