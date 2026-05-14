variable "vpc_cidr_block" {}
variable "subnet_cidr_block" {}
variable "availability_zone" {}
variable "env_prefix" {}
variable "instance_type" {}

# AMI Configuration
variable "ubuntu_ami_owners" {
  description = "AMI owners for Ubuntu"
  type        = list(string)
  default     = ["099720109477"] # Canonical
}

variable "ubuntu_ami_name_filter" {
  description = "AMI name filter for Ubuntu Jammy"
  type        = string
  default     = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
}
