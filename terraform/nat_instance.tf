# Data source to get the latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Security Group for NAT Instance
resource "aws_security_group" "nat_instance" {
  name_prefix = "${var.project_name}-nat-instance-"
  description = "Security group for NAT instance"
  vpc_id      = aws_vpc.main.id

  # Allow all traffic from private subnets
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [for subnet in aws_subnet.private : subnet.cidr_block]
    description = "Allow all traffic from private subnets"
  }

  # Allow SSH from your IP (optional, for debugging)
  # Uncomment and set your IP if needed
  # ingress {
  #   from_port   = 22
  #   to_port     = 22
  #   protocol    = "tcp"
  #   cidr_blocks = ["YOUR_IP/32"]
  #   description = "SSH access for debugging"
  # }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "${var.project_name}-nat-instance-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# NAT Instance
resource "aws_instance" "nat" {
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = var.nat_instance_type
  subnet_id                   = aws_subnet.public[0].id
  vpc_security_group_ids      = [aws_security_group.nat_instance.id]
  associate_public_ip_address = true
  source_dest_check           = false # Important for NAT functionality

  # User data to configure the instance as NAT
  user_data = <<-EOF
    #!/bin/bash
    # Enable IP forwarding
    echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
    sysctl -p
    
    # Configure iptables for NAT
    /sbin/iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
    /sbin/iptables -F FORWARD
    
    # Save iptables rules
    service iptables save
    
    # Ensure iptables starts on boot
    chkconfig iptables on
  EOF

  tags = {
    Name = "${var.project_name}-nat-instance"
    Type = "NAT"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Elastic IP for NAT Instance (optional, but recommended for consistency)
resource "aws_eip" "nat_instance" {
  instance = aws_instance.nat.id
  domain   = "vpc"

  tags = {
    Name = "${var.project_name}-nat-instance-eip"
  }

  depends_on = [aws_internet_gateway.main]
}
