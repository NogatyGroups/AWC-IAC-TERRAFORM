variable "region" {
  type = string
}

variable "aws_account_id" {
  type = string
}

variable "bucket_name" {
  type = string
}

variable "bucket_region" {
  type = string
}

variable "bucket_key" {
  type = string
}

variable "tf-s3crossreplicas-role" {
  type = string
  default = "s3crossreplicas-role"
  
}

variable "tf-s3crossreplicas-policy" {
  type = string
  default = "s3crossreplicas-policy"
}

variable "tf-bucket-source-s3crossreplicas" {
  type = string
  default = "nogaty-source-bucket"
  
}


variable "tf-bucket-destination-s3crossreplicas" {
  type = string
  default = "nogaty-cross-replicas"
  
}

variable "nogaty-us-east-vpc" {
  type = string
  default = "nogaty-us-east-vpc"
}

variable "nogaty-us-west-vpc" {
  type = string
  default = "nogaty-us-west-vpc"
}

variable "peer-region" {
  type = string
  default = "us-west-1"
  
}

variable "peer-owner-id" {
  type = string
  default = "712487951696"
}

variable "peering-vpc-name" {
  type = string
  default = "Nogaty-Peering-VPC"
}