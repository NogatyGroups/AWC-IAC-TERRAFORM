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
variable "tf-bucket-destination-s3crossreplicas" {
  type = string
  default = "nogaty-cross-replicas"
  
}