variable "deployment_tag" {
  description = "Tag to identify the deployment"
  type        = string
  default     = "devops-challenge"
} 

variable "allowed_ip_cidr" {
  description = "CIDR blocks allowed for SSH and WAF"
  type        = string
  default     = "82.43.64.101/32"
}

variable "runner_ip_cidr" {
  description = "CIDR blocks allowed for SSH and WAF"
  type        = string
  default     = "1.2.3.14/32"
}

variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "eu-west-1"
}

variable "azs" {
 type        = list(string)
 description = "Availability Zones"
 default     = ["eu-west-1a", "eu-west-1b"]
} 

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}


variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"

}

# Private subnet CIDDR Block  for the internal loadbalancer
variable "private_subnet_cidrs" {
  type = list(string)
  default = ["10.0.1.0/24","10.0.2.0/24"]
}

variable "public_subnet_cidrs" {
  type = list(string)
  default = ["10.0.3.0/24","10.0.4.0/24"]
}
