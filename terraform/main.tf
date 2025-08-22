/*
 * This file contains the main Terraform configuration for the CD infrastructure.
 * It sets up the VPC, subnets, security groups, and the EC2 instance.
 *
 * This version uses the account's default VPC to simplify the configuration.
 * It uses an IAM role for the EC2 instance to grant it ECR permissions,
 * which is the recommended and most secure practice.
 * It avoids using hard-coded access keys on the instance.
 */

# Configure the AWS provider with the specified region.
provider "aws" {
  region = "us-east-1"
}

# ---------------------------------
# Data Sources to find the Default VPC and a Public Subnet
# ---------------------------------

# Use a data source to find the default VPC in your account.
data "aws_vpc" "default" {
  default = true
}

# Use a data source to find a public subnet within the default VPC.
# This assumes the default VPC has a public subnet.
data "aws_subnet" "public" {
  vpc_id = data.aws_vpc.default.id
  filter {
    name   = "map-public-ip-on-launch"
    values = ["true"]
  }
  filter {
    name   = "availability-zone"
    values = ["us-east-1a"] # Specify a single AZ to prevent the "multiple subnets matched" error
  }
}

# ---------------------------------
# IAM Role and Policy for EC2 Instance
# ---------------------------------

/*
 * This section creates an IAM Role and an IAM Policy that allows the EC2 instance
 * to assume the role and get ECR authentication tokens.
 */

# Create an IAM Role for the EC2 instance.
resource "aws_iam_role" "ec2_instance_role" {
  name = "ec2-cd-server-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Create a policy with ECR read-only permissions.
resource "aws_iam_policy" "ecr_read_only_policy" {
  name = "ecr-read-only-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach the policy to the IAM role.
resource "aws_iam_role_policy_attachment" "ecr_read_only_attachment" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = aws_iam_policy.ecr_read_only_policy.arn
}

# Create an instance profile to associate the role with the EC2 instance.
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-cd-server-profile"
  role = aws_iam_role.ec2_instance_role.name
}

# ---------------------------------
# Security Group
# ---------------------------------

resource "aws_security_group" "instance_sg" {
  vpc_id      = data.aws_vpc.default.id
  name        = "cd-pipeline-instance-sg"
  description = "Allow inbound traffic for SSH and application ports."

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Be more restrictive in production
  }
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "cd-pipeline-instance-sg"
  }
}

# ---------------------------------
# EC2 Instance
# ---------------------------------

resource "aws_instance" "cd_server" {
  ami                         = "ami-020cba7c55df1f615" # Ubuntu 24.04 LTS (us-east-1)
  instance_type               = "t2.medium"
  # key_name                    = "new.key.pem" # Change to your SSH key pair name
  subnet_id                   = data.aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.instance_sg.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name # Associate the IAM profile here
  user_data_base64            = filebase64("user_data.sh")
  
  root_block_device {
    volume_size = 28
  }

  tags = {
    Name = "cd-pipeline-server"
  }
}

output "public-ip-address" {
  value = aws_instance.cd_server.public_ip
}
