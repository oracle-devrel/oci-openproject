resource "tls_private_key" "key01" {
  algorithm = "RSA"
  rsa_bits  = "2048"

  provisioner "local-exec" { # Create a "myKey.pem" to your computer!!
  command = "echo '${tls_private_key.key01.private_key_pem}' > ./myKey.pem"
  }

}