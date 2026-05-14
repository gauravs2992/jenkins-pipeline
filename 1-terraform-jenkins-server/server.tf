data "aws_caller_identity" "current" {}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = var.ubuntu_ami_owners

  filter {
    name   = "name"
    values = [var.ubuntu_ami_name_filter]
  }
}

resource "aws_instance" "my-server" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = "test_gaurav"
  subnet_id                   = aws_subnet.jenkins-subnet-1.id
  vpc_security_group_ids      = [aws_default_security_group.default-sg.id]
  availability_zone           = var.availability_zone
  associate_public_ip_address = true
  user_data                   = file("${path.module}/jenkins-script.sh")
  tags = {
    Name = "${var.env_prefix}-server"
  }
}
