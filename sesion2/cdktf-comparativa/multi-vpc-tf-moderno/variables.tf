variable "vpcs" {
  type = list(object({
    name   = string
    cidr   = string
    region = string
    az     = string
  }))
}