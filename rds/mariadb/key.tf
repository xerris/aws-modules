# resource "aws_key_pair" "mykeypair" {
#   key_name   = "mykeypair"
#   public_key = file(var.PATH_TO_PUBLIC_KEY)
# }


# Generates RSA Keypair
resource "tls_private_key" "webserver_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save Private key locally
resource "local_file" "private_key" {
  content  = tls_private_key.webserver_key.private_key_pem
  filename = "mykeypair.pem"
}

# Upload public key to create keypair on AWS
resource "aws_key_pair" "mykeypair" {
  key_name   = "mykeypair"
  public_key = tls_private_key.webserver_key.public_key_openssh
}