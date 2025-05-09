module "vpc_instances" {
  for_each = { for v in var.vpcs : v.name => v }

  source = "./modules/vpc-instance"

  name   = each.value.name
  cidr   = each.value.cidr
  region = each.value.region
  az     = each.value.az

  providers = {
    aws = each.value.region == "us-east-1" ? aws : aws.west
  }
}