# The Kubernetes provider is included in this file so the EKS module can complete successfully. Otherwise, it throws an error when creating `kubernetes_config_map.aws_auth`.
# You should absolutely **not** schedule deployments and services in this workspace. This keeps workspaces modular (one for provision EKS, another for scheduling Kubernetes resources) as per best practices.

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  token                  = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
}
provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    token                  = data.aws_eks_cluster_auth.cluster.token
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  }
}

resource "kubernetes_namespace" "ns_name" {
  metadata {
    name = "consul"  
  }
}
resource "kubernetes_secret" "consul-ent-license" {
  metadata {
    name = "consul-ent-license"
    namespace = "consul"
  }
  data = {
    "key" = file("${path.module}/License/consul.hclic")
  }
  type = "Opaque"
}

resource "kubernetes_secret" "consul-gossip-encryption-key" {
  metadata {
    name = "consul-gossip-encryption-key"
    namespace = "consul"
  }
  data = {
    "key" = var.consulencrypt
  }
  type = "Opaque"
}


resource "helm_release" "consul_server" {
  count = var.consulserver == "yes" ? 1:0 
  name       = "consul"
  namespace  = "consul"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "consul"
   values = [
    data.template_file.consul-server-helm.rendered
  ]
  depends_on = [
    kubernetes_secret.consul-gossip-encryption-key,
    kubernetes_secret.consul-ent-license
  ]
}




data "template_file" "consul-server-helm" {
  template = join("\n",tolist([
    file("${path.module}/Files/helm/server-apartition.yaml")
    ]))
  vars = {
    dcName = "${var.dc_name}"
  }
}
data kubernetes_secret agent-ca {
  count = var.consulserver == "yes" ? 1:0 
  metadata {
    name = "consul-ca-cert"
    namespace = "consul"
  }
  depends_on = [
    helm_release.consul_server
  ]
}

data kubernetes_secret agent-ca-key {
  count = var.consulserver == "yes" ? 1:0 
  metadata {
    name = "consul-ca-key"
    namespace = "consul"
  }
  depends_on = [
    helm_release.consul_server
  ]
}

data "kubernetes_service" "consul-partition-service" {
  count = var.consulserver == "yes" ? 1:0 
  metadata {
    name = "consul-partition-service"
    namespace = "consul"
  }
  depends_on = [
    helm_release.consul_server
  ]
}

data "kubernetes_service" "consul-ui" {
  count = var.consulserver == "yes" ? 1:0 
  metadata {
    name = "consul-ui"
    namespace = "consul"
  }
  depends_on = [
    helm_release.consul_server
  ]
}
#kubectl get secrets/consul-bootstrap-acl-token --template={{.data.token}} -n consul | base64 -D
data kubernetes_secret k8s-master-token {
  count = var.consulserver == "yes" ? 1:0 
  metadata {
    name = "consul-bootstrap-acl-token"
    namespace = "consul"
  }
  depends_on = [
    helm_release.consul_server
  ]
}

output "master_token" {
  value = var.consulserver == "yes" ? data.kubernetes_secret.k8s-master-token[0].data["token"]:""
}

output "caCert" {
  value = var.consulserver == "yes" ? data.kubernetes_secret.agent-ca[0].data["tls.crt"]:""
}

output "caKey" {
  value = var.consulserver == "yes" ? data.kubernetes_secret.agent-ca-key[0].data["tls.key"]:""
}

output partitionService {
  value = var.consulserver == "yes" ? data.kubernetes_service.consul-partition-service[0].status[0].load_balancer[0].ingress[0].hostname: ""
}

output consul-ui {
  value = var.consulserver == "yes" ? data.kubernetes_service.consul-ui[0].status[0].load_balancer[0].ingress[0].hostname: ""
}




