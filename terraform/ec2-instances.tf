################################################################################################
# Get AMI from aws market place
################################################################################################
data "aws_ami" "ubuntu-a" {
    provider = aws.vpc-a
    region = var.region-us
    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
    }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["amazon"] 
}


data "aws_ami" "ubuntu-b" {
    provider = aws.vpc-b
    region = var.region-eu
    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
    }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["amazon"] 
}

################################################################################################
# Create ssh key
################################################################################################
## Create keypaire
resource "aws_key_pair" "nogaty-keys-a" {
  provider = aws.vpc-a
  key_name   = var.key_pair.name
  public_key = var.key_pair.public_key
}
resource "aws_instance" "nogaty-ec2-vpc-a" {
    count = 1
    provider = aws.vpc-a
    region = var.region-eu
    ami           = var.ec2-ami-a
    instance_type = "t3.micro"
    key_name = aws_key_pair.nogaty-keys-a.key_name
    subnet_id = aws_subnet.public-subnet-a[count.index].id
    depends_on = [ aws_subnet.public-subnet-a ]
    tags = {
      Name = "NogatyEC2VPC-A-${count.index}"
    }
}


resource "aws_key_pair" "nogaty-keys-b" {
  provider = aws.vpc-b
  key_name   = var.key_pair.name
  public_key = var.key_pair.public_key
}
resource "aws_instance" "nogaty-ec2-vpc-b" {
    count = 1
    provider = aws.vpc-b
    region = var.region-eu
    ami           = var.ec2-ami-b
    key_name = aws_key_pair.nogaty-keys-b.key_name
    subnet_id = aws_subnet.public-subnet-b[count.index].id
    instance_type = "t3.micro"
    depends_on = [ aws_subnet.public-subnet-b ]
    tags = {
      Name = "NogatyEC2VPC-B-${count.index}"
    }
}