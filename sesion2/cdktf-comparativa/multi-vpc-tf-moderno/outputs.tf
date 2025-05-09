output "instance_public_ips" {
  value = {
    for k, v in module.vpc_instances : k => v.instance_public_ip
  }
}