
resource "tls_private_key" "devops" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Save private key to file
resource "local_file" "private_key" {
  content  = tls_private_key.devops.private_key_pem
  filename = "${path.module}/Artifacts/${var.deployment_tag}-private_key.pem"
}

# Save public key to file
resource "local_file" "public_key" {
  content  = tls_private_key.devops.public_key_openssh
  filename = "${path.module}/Artifacts/${var.deployment_tag}-public_key.pub"
}

resource "aws_key_pair" "devops-challenge-key" {
  depends_on = [ 
    tls_private_key.devops
    ]
  key_name   = "devops-challenge-key"
  public_key = tls_private_key.devops.public_key_openssh
}