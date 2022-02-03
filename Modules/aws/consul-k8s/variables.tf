variable node_count{
    type = number
    description = "capacity of eks cluster"
}

variable security_group_id {
    type = string
}

variable cluster_name{
    type = string
}

variable vpc_id{
    type = string
}

variable private_subnets{
    type = list(string)
}


variable public_subnets{
    type = list(string)
}
variable consulserver{
    type =  string
}

variable consulencrypt {
    type = string
}

variable caCert {
    type = string
    default = ""
}
variable caKey {
    type = string
    default = ""
}


variable partitionService{
  type = string
  default = ""
}

variable masterToken{
    type = string 
    default = ""
}

variable dc_name{
    type = string 
    default = "dc1"
}

variable partitionName{
    type = string 
    default = "default"
}
# variable gossipencryption{
#     type = string
# }
