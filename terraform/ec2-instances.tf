data "aws_ami" "ubuntu-a" {
    provider = aws.vpc-a
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

resource "aws_instance" "nogaty-ec2-vpc-a" {
    provider = aws.vpc-a
    ami           = data.aws_ami.ubuntu-a.id
    instance_type = "t3.micro"

    tags = {
      Name = "nogaty-ec2-vpc-a"
    }
}

resource "aws_instance" "nogaty-ec2-vpc-b" {
    provider = aws.vpc-a
    ami           = data.aws_ami.ubuntu-b.id
    instance_type = "t3.micro"

    tags = {
      Name = "nogaty-ec2-vpc-b"
    }
}