output "public_ip" {
    value = module.ec2-instance-public["first"].public_ip
}