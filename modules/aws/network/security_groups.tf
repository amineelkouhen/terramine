############################################################
# Security Groups

resource "aws_security_group" "allow-global" {
  name        = "${var.name}-sg-allow-global"
  description = "Allow External inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description       = "ICMP Protocol"
    from_port         = -1
    to_port           = -1
    protocol          = "icmp"
    cidr_blocks       = ["0.0.0.0/0"]
  }

  ingress {
    description      = "SSH from anywhere"
    from_port         = 22
    to_port           = 22
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
  }

  ingress {
    description       = "DNS traffic"
    from_port         = 53
    to_port           = 53
    protocol          = "udp"
    cidr_blocks       = ["0.0.0.0/0"]
  }
  
  ingress {
    description       = "DNS traffic"
    from_port         = 53
    to_port           = 53
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
  }

  ingress {
    description      = "HTTP from anywhere"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
  }

  ingress {
    description      = "TLS from anywhere"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
  }

  ## Grafana Port

  ingress {
    description       = "Grafana default port"
    from_port         = 3000
    to_port           = 3000
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
  }

  ## Redis Special Ports
  
  ingress {
    description       = "mDNS traffic"
    from_port         = 5353
    to_port           = 5353
    protocol          = "udp"
    cidr_blocks       = ["0.0.0.0/0"]
  }

  ingress {
    description       = "RE UI traffic"
    from_port         = 8443
    to_port           = 8443
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
  }

  ingress {
    description       = "Rest API traffic"
    from_port         = 9443
    to_port           = 9443
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
  }

  ingress {
    description       = "FTP traffic"
    from_port         = 21
    to_port           = 21
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
  }

  ingress {
    description      = "REST API (non-secure)"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Metric exported and managed by the web proxy"
    from_port        = 8070
    to_port          = 8070
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Metric exported and managed by the web proxy"
    from_port        = 8071
    to_port          = 8071
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Discovery Service Traffic"
    from_port        = 8001
    to_port          = 8001
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ## Prometheus Port

  ingress {
    description       = "Prometheus UI port"
    from_port         = 9090
    to_port           = 9090
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
  }

  ## Redis DB Ports

  ingress {
    description      = "Discovery Service Traffic"
    from_port        = 10000
    to_port          = 19999
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ## outbound traffic

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = merge("${var.resource_tags}",{
    Name = "${var.name}-allow-global"
  })
}

resource "aws_security_group" "allow-local" {
  name = "${var.name}-sg-allow-local"
  description = "Allow inbound traffic from local VPC"
  vpc_id = aws_vpc.vpc.id

  ingress {
    description      = "All internal Traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["${var.vpc_cidr}"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = merge("${var.resource_tags}",{
    Name = "${var.name}-allow-local"
  })
}