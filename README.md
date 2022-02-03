# Readme
This terraform code will create:
- A VPC with CIDR: 192.168.0.0/16
- An EKS cluster with 3 nodes
- A consul DC with TLS and ACLs enabled

1. First make sure to configure the access against aws 
   ex.:
   ```
   aws configure
   ```
2. In the providers.tf file make sure to select the aws region you wish to deploy the EKS cluster in.
3. Open the terraform.tfvars file and make sure to verify the value
4. Have a look at the main.tf file
5. Run ``terraform plan``
6. Run ``terraform apply``