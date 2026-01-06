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

variable "nogaty-eu-central-vpc" {
  type = string
  default = "nogaty-eu-central-vpc"
}

variable "peer-region" {
  type = string
  default = "eu-central-1"
  
}

variable "peering-vpc-name" {
  type = string
  default = "Nogaty-Peering-VPC"
}



##############################################################################################
# 
##############################################################################################
variable "region-us" {
  type = string
  default = "us-east-1"
}

variable "region-eu" {
  type = string
  default = "eu-central-1"
}

variable "env" {
  type = string
  default = "Production"
  
}


variable "key_pair" {
  type = object({
    name = string,
    public_key = string
  })
  default = {
    name = "Nogaty-Devops-Key",
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC2crmyOLf9AgG2xvPQ/joZkFLMm2Hpq378Pboy4Y/J5+qPiwhEbnMR20e7hNKoxPnMi3H2dawgHwW+CCQwi6ZF0xCxxo2veAdaK3XuENQq9JKinqgl1DePqklLYpzRTXeSkS7uSxXmkp/VQt2p+EL2tg1NE91VYSEcLoUGncwmTEknzvoHDWoHRGsToPZyi1rubt/nROTKEU4dmt0zzftkyFo3C1ndX1swpE0w08x2Qq2iF1V/eHmkpeaAu4d7ofbCfezE+8f6CphCZ0tjC3EZxs/si7CTyKt9njWWuC5cHIjJrPVrOatB4JoV4nVO3qMy8yfU+j4A0KYMvMUdE796FRNYcmgNVIRELMBVJy2DS0/rM3UAPRFI+mFf8wvcEbzXD2mrJ7BUdsLxAt2VSxZ12YYT44hvbXdzdCSFFsiuC+DpW9ZfvgDRcMCA0N+K3VORLMBD9yWv9mg/VjGkM7bU90E4PKIlFRVvF43exZ9rGBfmtwf/7QWOBMu1Jrmgkls= Nogaty-devops-key"
  }
}



variable "igw-vpca" {
  type = string
  default = "igw-vpca"
  
}

variable "igw-vpcb" {
  type = string
  default = "igw-vpcb"
  
}

variable "cidr-block-a" {
  type = string
  default= "10.1.0.0/16"
}

variable "cidr-block-b" {
  type = string
  default= "192.168.0.0/16"
}


#variable "instance-tenancy" {
#  type = string
#}


variable "pub-sub-name-a" {
  type = string
  default = "Public-subnet-A"
}

variable "pub-sub-name-b" {
  type = string
  default = "Public-subnet-B"
}

variable "pub-subnet-count-a" {
  type = number
  default = 3
}

variable "pub-subnet-count-b" {
  type = number
  default = 3
}

variable "pub-cidr-block-a" {
    type = list(string)
    default = [ "10.1.1.0/24","10.1.2.0/24", "10.1.3.0/24" ]
  
}

variable "pub-cidr-block-b" {
    type = list(string)
    default = [ "192.168.1.0/24","192.168.2.0/24", "192.168.3.0/24" ]
  
}

variable "pub-availability-zone-a" {
  type = list(string)
  default = [ "us-east-1a","us-east-1b","us-east-1c" ]
}

variable "pub-availability-zone-b" {
  type = list(string)
  default = [ "eu-central-1a","eu-central-1b","eu-central-1c" ]
}

variable "pri-sub-name-a" {
  type = string
  default = "Private-subnet-A"
  
}
variable "pri-sub-name-b" {
  type = string
  default = "Private-subnet-B"
}
variable "pri-subnet-count-a" {
  type = number
  default = 3
}
variable "pri-subnet-count-b" {
  type = number
  default = 3
}


variable "pri-cidr-block-a" {
    type = list(string)
  default = [ "10.1.10.0/24","10.1.11.0/24", "10.1.12.0/24" ]
}
variable "pri-cidr-block-b" {
    type = list(string)
    default = [ "192.168.10.0/24","192.168.11.0/24", "192.168.12.0/24" ]
}
variable "pri-availability-zone-a" {
  type = list(string)
  default = [ "us-east-1a","us-east-1b","us-east-1c" ]
}

variable "pri-availability-zone-b" {
  type = list(string)
  default = [ "eu-central-1a","eu-central-1b","eu-central-1c" ]
}

variable "public-rta-name" {
  type = string
  default = "public-rta-name"
}

variable "public-rtb-name" {
  type = string
  default = "public-rtb-name"
}

variable "eip-name-a" {
  type = string
  default = "Elastic IP A"
}

variable "eip-name-b" {
  type = string
  default = "Elastic IP B"
}

variable "ngw-name-a" {
  type = string
  default = "Nat Gateway A"
}
variable "ngw-name-b" {
  type = string
  default = "Nat Gateway B"
}
variable "private-rta-name" {
  type = string
  default = "private-rta-name"
}
variable "private-rtb-name" {
  type = string
  default = "private-rtb-name"
}

variable "sg-a-name" {
  type = string
  default = "Security-grp-A"
}

variable "sg-b-name" {
  type = string
  default = "Security-grp-B"
}