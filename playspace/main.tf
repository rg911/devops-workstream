#
# root module
# Playspace to mess around with the tools
# See docs/credits.md for contact/support details; hacked together by Alex Stanhope
#

# set up the AWS environment
module "aws_background" {
  source = "./aws_background"
  aws_region = "${var.aws_region}"
  key_name = "${var.key_name}"
  # bastion_ssh_port = "${var.bastion_ssh_port}"
}

