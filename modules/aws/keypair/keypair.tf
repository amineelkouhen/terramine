terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}


############################################################
# Key Pair

resource "aws_key_pair" "keypair" {
  key_name = "${var.name}-keypair"
  public_key = file(var.ssh_public_key)

  tags = merge("${var.resource_tags}",{
    Name = "${var.name}"
  })
}
