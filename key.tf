resource "aws_key_pair" "ssh_key" {
  key_name   = "terraform-key"
  public_key = file("F:/terraform/keys/terraform-key.pub")
}

