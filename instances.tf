# Get Amazon Linux 2 AMI for the deployment region
data "aws_ami" "amazon-linux-2" {
 most_recent = true

 filter {
   name   = "owner-alias"
   values = ["amazon"]
 }


 filter {
   name   = "name"
   values = ["amzn2-ami-hvm-*-x86_64-gp2"]
 }
}

# Bastion Host
resource "aws_instance" "bastion" {
  ami           = data.aws_ami.amazon-linux-2.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.devops-challenge-key.key_name
  subnet_id     = aws_subnet.public_subnets[0].id
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  tags = { 
    Deployment = var.deployment_tag
    Name = "bastion-host" 
    }
}

# Application Servers
resource "aws_instance" "app" {
  count             = 2
  ami               = data.aws_ami.amazon-linux-2.id
  instance_type     = var.instance_type
  key_name          = aws_key_pair.devops-challenge-key.key_name
  subnet_id         = aws_subnet.private_subnets[count.index].id
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              echo "Running user data script" > /home/ec2-user/userdata.log
              # need python 3.8 for ansible
              amazon-linux-extras enable python3.8
              yum clean metadata
              yum install python38 python38-pip -y
              ln -sf /usr/bin/python3.8 /usr/bin/python3
              yum update -y
              EOF

  provisioner "remote-exec" {
    inline = [
      "echo \"SSH connection is now available!\" > /home/ec2-user/test.log"
      ]
      connection {
      type     = "ssh"
      bastion_host        = aws_instance.bastion.public_ip
      bastion_user        = "ec2-user"
      bastion_host_key    = "${file("${local_file.public_key.filename}")}"
      bastion_private_key = "${file("${local_file.private_key.filename}")}"
  
      user     = "ec2-user"
      private_key = "${file("${local_file.private_key.filename}")}"
  
      host     = self.private_dns
    }
}
   tags = { 
    Deployment = var.deployment_tag
    Name = "app-server-${count.index + 1}" 
    }
}


