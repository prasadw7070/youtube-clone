resource "aws_instance" "web" {
  ami                    = "ami-053b0d53c279acc90"      #change ami id for different region
  instance_type          = "t2.medium"
  key_name               = "PROJECT"              #change key name as per your setup
  vpc_security_group_ids = [aws_security_group.Monitoring-Server-SG.id]
  user_data              = templatefile("./prometheus-grafana-installation.sh", {})

  tags = {
    Name = "Monitoring-Server"
  }

  root_block_device {
    volume_size = 20
  }
}

resource "aws_security_group" "Monitoring-Server-SG" {
  name        = "Monitoring-Server-SG"
  description = "Allow TLS inbound traffic"

  ingress = [
    for port in [22, 80, 443, 9090, 9100, 3000] : {
      description      = "inbound rules"
      from_port        = port
      to_port          = port
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Monitoring-Server-SG"
  }
}
