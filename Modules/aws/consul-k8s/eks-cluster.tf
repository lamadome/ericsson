data "aws_vpc" "consul_vpc" {
  id = var.vpc_id
}
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = var.cluster_name
  version = "17.22.0"
  cluster_version = "1.21"
  subnets         = var.public_subnets

  vpc_id = data.aws_vpc.consul_vpc.id
  tags	= {
        consulserver = var.consulserver
        }
  workers_group_defaults = {  
    root_volume_type = "gp2"
  }

  worker_groups = [
    {
      name                          = "consul-aks-node-group"
      instance_type                 = "t2.medium"
      additional_security_group_ids = var.security_group_id
      asg_desired_capacity          = var.node_count
    }
  ]
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}
