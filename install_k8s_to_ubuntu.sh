#!/bin/bash
# Copyright (C) 2019, case
# All rights reserved.
#
# Filename   : install_k8s_to_ubuntu.sh
# Description: use kubeadm install k8s to ubuntu18.04
# Version    : 1.0
# Date       : 2019-04-20
# Last Update: 2019-04-20
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

echo "net.bridge.bridge-nf-call-iptables = 1" >> /etc/sysctl.conf

echo "net.bridge.bridge-nf-call-ip6tables = 1" >> /etc/sysctl.conf

sysctl -p
#from https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/

#install kube...
apt-get update && apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl


# Install Docker CE
## Set up the repository:
### Install packages to allow apt to use a repository over HTTPS
apt-get update && apt-get install -y  apt-transport-https ca-certificates curl software-properties-common

### Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

### Add Docker apt repository.
add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) \
  stable"

## Install Docker CE.
apt-get update && apt-get install -y docker-ce=18.06.2~ce~3-0~ubuntu

# Setup daemon.
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

mkdir -p /etc/systemd/system/docker.service.d

# Restart docker.
systemctl daemon-reload
systemctl restart docker

#start init flannel
kubeadm init --pod-network-cidr=10.244.0.0/16


#To start using your cluster, you need to run the following as a regular user:
#mkdir -p $HOME/.kube
#sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
#sudo chown $(id -u):$(id -g) $HOME/.kube/config

#as root run the following and add to onboot script

#set environment variable reboot also useful
echo "export KUBECONFIG=/etc/kubernetes/admin.conf" >> /etc/profile
source  /etc/profile
#master for node use
kubectl taint nodes --all node-role.kubernetes.io/master-

#Installing a pod network add-on flannel
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/a70459be0084506e4ec919aa1c114638878db11b/Documentation/kube-flannel.yml
