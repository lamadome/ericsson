#!/bin/bash

#wait for box
sleep 30

#hashicorp packages
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

#install packages
sudo apt update -y
sudo apt install awscli consul-enterprise vault-enterprise nomad jq -y
sudo apt install awscli jq zip unzip -y

#curl https://releases.hashicorp.com/consul/1.11.0+ent-beta2/consul_1.11.0+ent-beta3_linux_amd64.zip --output consul1-11.zip
#sudo mkdir consul
#sudo unzip consul1-11.zip -d consul

#sudo mv consul/consul /usr/bin/consul -f
#vault-enterprise=1.7.1+ent nomad-enterprise=1.0.4+ent docker.io jq -y

#envoy
curl https://func-e.io/install.sh | sudo bash -s -- -b /usr/local/bin
echo "Installing Envoy"
func-e use 1.18.3
sudo cp ~/.func-e/versions/1.18.3/bin/envoy /usr/local/bin/
echo "Envoy Installed"
mkdir /opt/vault
sudo mv /home/ubuntu/license/license.hclic /opt/consul/license.hclic
sudo mv /home/ubuntu/license/vault.hclic /opt/vault/license.hclic

sudo mkdir -p /opt/consul/tls/
sudo mkdir -p /opt/policies


sudo mv /home/ubuntu/policies/ /opt/consul/

cd /opt/consul/tls/

sudo consul tls ca create
sudo consul tls cert create -server -dc dc-1 -node "*"
sudo consul tls cert create -client -dc dc-1
sudo consul tls cert create -server -dc dc-2 -node "*"
sudo consul tls cert create -client -dc dc-2

#pgk checks
#aws cli
aws --version
if [ $? -ne 0 ]
then
  echo "Error checking AWS cli version"
  exit 1
fi
#consul
consul --version
if [ $? -ne 0 ]
then
  echo "Error checking Consul version"
  exit 1
fi

#jq
jq --version
if [ $? -ne 0 ]
then
  echo "Error checking jq version"
  exit 1
fi
#envoy
envoy --version
if [ $? -ne 0 ]
then
  echo "Error checking Envoy version"
  exit 1
fi

exit 0
