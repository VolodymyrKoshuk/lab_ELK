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
  instance_type               = "t3.small"
  key_name                    = "vova-key-linuxaws-prod-stokholm"
  associate_public_ip_address = true
  iam_instance_profile        = "AmazonSSMRoleForInstancesQuickSetup"
  vpc_security_group_ids      = [aws_security_group.sg_elk.id]
  user_data                   = templatefile("scripts/init.sh.tftpl", { 
    pub_key = file("credentials/id_rsa.pem.pub")
    conf_log = file("Logstash/logstash.conf")
   })
 
  putin_khuylo                = true

  root_block_device = [
    {
      volume_type           = "gp3"
      volume_size           = "20"
      delete_on_termination = "true"
    }
  ]




  tags = {
    Terraform = true
    Task = "Check ELK stack"
  }
}


resource "aws_security_group" "sg_elk" {
  name   = "Security Group for ELK Server"

#Rules to ingress trafic
  dynamic "ingress" {
    for_each = ["22", "5000", "9200", "80", "8080", "443", "1234", "1235", "1236"]

    content {
      from_port        = ingress.value
      to_port          = ingress.value
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
    }
  }


# Rule for egress to all internet
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Role = "SG for Elk Server"
    Terraform = true
  }
}