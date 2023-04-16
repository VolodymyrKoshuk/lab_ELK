data "aws_ami" "amazon_linux2" {
  owners = ["137112412989"]
  most_recent = true

  filter {
    name = "name"
    values = ["amzn2-ami-kernel-*"]
  }
}


module "ec2-instance-public" {
  source   = "terraform-aws-modules/ec2-instance/aws"
  version  = "4.3.0"
  for_each = toset(["first"]) # Meta-argument to create multiple servers

  name     = "ELK AWS Linux #${each.value}"

  ami                         = data.aws_ami.amazon_linux2.id
  instance_type               = "t3.micro"
  key_name                    = "vova-key-linuxaws-prod-stokholm"
  associate_public_ip_address = true
  iam_instance_profile        = "AmazonSSMRoleForInstancesQuickSetup"
 
  putin_khuylo                = true

  root_block_device = [
    {
      volume_type           = "gp3"
      volume_size           = "10"
      delete_on_termination = "true"
    }
  ]


  tags = {
    Terraform = true
    Task = "Check ELK stack"
  }
}

