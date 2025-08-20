/*
 * This file contains the main Terraform configuration for the CD infrastructure.
 * It sets up the VPC, subnets, security groups, and the EC2 instance.
 */

# Configure the AWS provider with the specified region.
provider "aws" {
  region = "us-east-1"
}
/*
# ---------------------------------
# VPC and Networking
# ---------------------------------

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "cd-pipeline-vpc"
  }
}

# Create a private subnet for the EC2 instance.
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a" # Change to your preferred AZ
  tags = {
    Name = "cd-pipeline-private-subnet"
  }
}

# Create an Internet Gateway for outbound traffic from the VPC.
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "cd-pipeline-igw"
  }
}

# Create an Elastic IP for the NAT Gateway.
resource "aws_eip" "nat" {
  tags = {
    Name = "cd-pipeline-nat-eip"
  }
}

# Create a NAT Gateway in the private subnet to allow outbound internet access for the EC2 instance.
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.private.id
  tags = {
    Name = "cd-pipeline-nat-gateway"
  }
}

# Create a route table and associate it with the private subnet.
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.main.id
  }
  tags = {
    Name = "cd-pipeline-private-route-table"
  }
}

# Associate the private route table with the private subnet.
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}
*/
# ---------------------------------
# Security Groups
# ---------------------------------

# Security group for the EC2 instance.
resource "aws_security_group" "instance_sg" {
#  vpc_id      = aws_vpc.main.id
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
    cidr_blocks = ["0.0.0.0/0"] # Minikube services will be exposed on this port
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
  instance_type               = "t2.medium" # t2.micro might be too small for minikube
#  key_name                    = "new.key.pem" # Change to your SSH key pair name
#  subnet_id                   = aws_subnet.private.id
#  vpc_security_group_ids      = [aws_security_group.instance_sg.id]
  associate_public_ip_address = true
  user_data_base64            = filebase64("user_data.sh") # Use filebase64 for the script

  tags = {
    Name = "cd-pipeline-server"
  }
}

# ---------------------------------
# IAM User and Policy for ECR
# ---------------------------------

/*
 * This section creates an IAM user and an IAM policy with ECR permissions
 * and attaches the policy to the user.
 *

resource "aws_iam_user" "ecr_ci_user" {
  name = "ecr-ci-user"
  tags = {
    Name = "ECR-CI-User"
  }
}

resource "aws_iam_policy" "ecr_access_policy" {
  name = "ecr-ci-access-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "ecr_access_attachment" {
  user       = aws_iam_user.ecr_ci_user.name
  policy_arn = aws_iam_policy.ecr_access_policy.arn
}

resource "aws_iam_access_key" "ecr_ci_user_access_key" {
  user = aws_iam_user.ecr_ci_user.name
}
*/