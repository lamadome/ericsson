variable vpc_name{
    type = string
    default = ""
}

resource "random_string" "env" {
  length  = 4
  special = false
  upper   = false
  number  = false
}

variable createVPC{
  type = bool
  description = "Create a vpc or use an existing one"
  default = true
}

variable vpc_ID{
  type = string
  description = "VPC id"
  default = ""
}



variable public_subnets {
  type = list(string)
  default = ["10.0.4.0/24", "10.0.5.0/24", "10.0.7.0/24"]
}
variable private_subnets {
  type = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}
variable cidr {
  type = string
  default = "10.0.0.0/16"
}