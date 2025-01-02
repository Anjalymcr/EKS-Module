variable "region" {
  description = "the AWS region in which resources are created, you must set the availability_zones variable as well if you define this value to something other than the default"
  default     = "ap-southeast-2"
}

variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
}

variable "aws-access-key" {
  description = "AWS access key"
  type        = string
}

variable "aws-secret-key" {
  description = "AWS secret key"
  type        = string
}

variable "iam_user_name" {
  description = "IAM user name"
  type        = string
}

variable "project" {
  description = "Project name used for tags"
  type        = string
  default     = "Wilt"
}

variable "aws_vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Number of different AZs to use"
  type        = number
  default     = 2
}

variable "ssh_public_key_path" {
  description = "SSH public key path "
  type        = string
  default     = "~/.ssh/dark-watch-key.pub"
}

variable "key_name" {
  description = "Name of the key pair"
  type        = string
  default     = "dark-watch-key"
}

variable "control_cidr" {
  description = "CIDR for maintenance: inbound traffic will be allowed from this IPs"
  type        = list(string)
}

variable "jenkins_ip_address" {
  description = "jenkins_ip_address"
  type = string
}

variable "bastion_host_instance_type" {
  description = "Bastion host instance type"
  type        = string
  default     = "t3.small"
}

variable "bastion_host_ami" {
  description = "Bastion host AMI"
  type        = string
  default     = "ami-0146fc9ad419e2cfd"
}

## Variables for EKS
variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "Wilt-eks-cluster"
}

variable "eks_node_group_name" {
  description = "Name of the EKS node group"
  type        = string
  default     = "Wilt-node-group"
}

variable "eks_cluster_version" {
  description = "EKS cluster version"
  type        = string
  default     = "1.31"
}

variable "node_instance_type" {
  description = "Node instance type"
  type        = string
  default     = "t3.small"
}


## Variables for RDS

variable "POSTGRES_DB" {
  description = "RDS database name"
  type        = string
  default     = "wiltdb"
}

variable "POSTGRES_USER" {
  description = "RDS database user"
  type        = string
}

variable "POSTGRES_PASSWORD" {
  description = "RDS database password"
  type        = string  
}

variable "db_instance_class" {
  description = "RDS database instance class"
  type        = string
  default     = "db.t3.micro"
}

