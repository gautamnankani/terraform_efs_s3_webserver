/////////////////////////////////////////////////////////////////// EC2_INSTANCE AND EFS

// security group creation
resource "aws_security_group" "my_sec" {
  name        = "sec_grp"
  description = "Allow ssh, http and nfs inbound traffic"

  ingress {
    description = "ssh from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
	  description = "NFS"
	  from_port   = 2049
	  to_port     = 2049
	  protocol    = "tcp"
	  cidr_blocks = ["0.0.0.0/0"]
	}
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}
