data "aws_ami" "ubuntu" {
  owners = ["self"]

  most_recent = true

  filter {
    name   = "name"
    values = ["hashistack-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

module vpc {
    source ="./Modules/aws/vpc"
    vpc_name = "consul-dc-eks"
    public_subnets=["192.168.4.0/24", "192.168.5.0/24", "192.168.7.0/24"]
    private_subnets=["192.168.1.0/24", "192.168.2.0/24", "192.168.3.0/24"]
    cidr="192.168.0.0/16"
}


resource "random_id" "consul_encrypt" {
  byte_length = 16
}

module consul_eks_cluster{
    source = "./Modules/aws/consul-k8s"
    node_count = 3
    security_group_id = module.vpc.security_group_id
    vpc_id = module.vpc.vpc_id
    private_subnets = module.vpc.private_subnets
    public_subnets = module.vpc.public_subnets
    consulserver = "yes"
    consulencrypt = random_id.consul_encrypt.b64_std
    dc_name = var.dc_name
    cluster_name = var.k8s_cluster_name
}

output "consul_m_token" {
  value = module.consul_eks_cluster.master_token
  description = "consul token"
  sensitive = true
}

output "consul-eks-ui" {
  value = module.consul_eks_cluster.consul-ui
  description = "consul UI URL"
}


