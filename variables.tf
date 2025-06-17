variable "region" {
  description = "value of the region where the resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "common_tags" {
  description = "Common tags to apply to all resources."
  type        = map(string)
  default = {
    Project = "MULTIVENDOR-PROJECT"
    Name    = "LAB"
    Vendor  = "ALL"
  }
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "MULTIVENDOR-VPC"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "172.16.0.0/16"
}

variable "availability_zone" {
  description = "availability zones in the region"
  type        = string
  default     = "us-east-1a"
}

# Subnet Variables
variable "subnet_configs" {
  description = "A map of subnet configurations including name and CIDR."
  type = map(object({
    cidr_block            = string
    auto_assign_public_ip = bool
    vendor                = string
  }))
  default = {
    "PUBLIC-SUBNET" = {
      cidr_block            = "172.16.5.0/24"
      auto_assign_public_ip = false # Overridden by elastic IP for target server
      vendor                = "ALL"
    },
    "MANAGEMENT-SUBNET" = {
      cidr_block            = "172.16.10.0/24"
      auto_assign_public_ip = false
      vendor                = "ALL"
    },
    "VENDOR1-SUBNET" = {
      cidr_block            = "172.16.101.0/24"
      auto_assign_public_ip = false
      vendor                = "VENDOR1"
    },
    "VENDOR2-SUBNET" = {
      cidr_block            = "172.16.102.0/24"
      auto_assign_public_ip = false
      vendor                = "VENDOR2"
    },
    "VENDOR3-SUBNET" = {
      cidr_block            = "172.16.103.0/24"
      auto_assign_public_ip = false # One subnet had this set to Yes
      vendor                = "VENDOR3"
    }
  }
}

#Network Interface Variables
variable "network_interface_configs" {
  description = "A map of network interface configurations including subnet and private IP."
  type = map(object({
    subnet_key        = string
    private_ip_suffix = number
    is_primary        = bool
    vendor            = string
  }))
  default = {
    "VENDOR1-VICTIM-WIN-PRIMARY-ENI" = {
      subnet_key        = "VENDOR1-SUBNET"
      private_ip_suffix = 10
      is_primary        = true
      vendor            = "VENDOR1"
    },
    "VENDOR1-VICTIM-WIN-MGMT-ENI" = {
      subnet_key        = "MANAGEMENT-SUBNET"
      private_ip_suffix = 10
      is_primary        = false
      vendor            = "VENDOR1"
    },
    "VENDOR1-VICTIM-UBUNTU-PRIMARY-ENI" = {
      subnet_key        = "VENDOR1-SUBNET"
      private_ip_suffix = 11
      is_primary        = true
      vendor            = "VENDOR1"
    },
    "VENDOR1-VICTIM-UBUNTU-MGMT-ENI" = {
      subnet_key        = "MANAGEMENT-SUBNET"
      private_ip_suffix = 11
      is_primary        = false
      vendor            = "VENDOR1"
    },
    "VENDOR2-VICTIM-WIN-PRIMARY-ENI" = {
      subnet_key        = "VENDOR2-SUBNET"
      private_ip_suffix = 10
      is_primary        = true
      vendor            = "VENDOR2"
    },
    "VENDOR2-VICTIM-WIN-MGMT-ENI" = {
      subnet_key        = "MANAGEMENT-SUBNET"
      private_ip_suffix = 12
      is_primary        = false
      vendor            = "VENDOR2"
    },
    "VENDOR2-VICTIM-UBUNTU-PRIMARY-ENI" = {
      subnet_key        = "VENDOR2-SUBNET"
      private_ip_suffix = 11
      is_primary        = true
      vendor            = "VENDOR2"
    },
    "VENDOR2-VICTIM-UBUNTU-MGMT-ENI" = {
      subnet_key        = "MANAGEMENT-SUBNET"
      private_ip_suffix = 13
      is_primary        = false
      vendor            = "VENDOR2"
    },
    "VENDOR3-VICTIM-WIN-PRIMARY-ENI" = {
      subnet_key        = "VENDOR3-SUBNET"
      private_ip_suffix = 10
      is_primary        = true
      vendor            = "VENDOR3"
    }
    "VENDOR3-VICTIM-WIN-MGMT-ENI" = {
      subnet_key        = "MANAGEMENT-SUBNET"
      private_ip_suffix = 14
      is_primary        = false
      vendor            = "VENDOR3"
    },
    "VENDOR3-VICTIM-UBUNTU-PRIMARY-ENI" = {
      subnet_key        = "VENDOR3-SUBNET"
      private_ip_suffix = 10
      is_primary        = true
      vendor            = "VENDOR3"
    },
    "VENDOR3-VICTIM-UBUNTU-MGMT-ENI" = {
      subnet_key        = "MANAGEMENT-SUBNET"
      private_ip_suffix = 15
      is_primary        = false
      vendor            = "VENDOR3"
    }
  }
}

# New variable for your SSH Key Pair
# variable "key_pair_name" {
#   description = "The name of the EC2 Key Pair to allow SSH access."
#   type        = string
#   default     = "Key-projectLab" #Created manually in AWS console
# }
# New variable for instance configurations
variable "instance_configs" {
  description = "A map of instance configurations including associated ENIs."
  type = map(object({
    instance_type           = string
    vendor                  = string
    network_interfaces_keys = list(string) # List of keys from var.network_interface_configs
  }))
  default = {
    "VENDOR1-VICTIM-UBUNTU" = {
      instance_type           = "t2.micro"
      vendor                  = "VENDOR1"
      network_interfaces_keys = ["VENDOR1-VICTIM-UBUNTU-PRIMARY-ENI", "VENDOR1-VICTIM-UBUNTU-MGMT-ENI"]
    },
    "VENDOR2-VICTIM-UBUNTU" = {
      instance_type           = "t2.micro"
      vendor                  = "VENDOR2"
      network_interfaces_keys = ["VENDOR2-VICTIM-UBUNTU-PRIMARY-ENI", "VENDOR2-VICTIM-UBUNTU-MGMT-ENI"]
    },
    "VENDOR3-VICTIM-UBUNTU" = {
      instance_type           = "t2.micro"
      vendor                  = "VENDOR3"
      network_interfaces_keys = ["VENDOR3-VICTIM-UBUNTU-PRIMARY-ENI", "VENDOR3-VICTIM-UBUNTU-MGMT-ENI"]
    }
  }
}
#variable for key pair
variable "key_name" {
  description = "The name of the EC2 Key Pair to allow SSH access."
  type        = string
  default     = "udbhas-ec2-key" #Created with the tf code
}