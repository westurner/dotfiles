#!/bin/sh

# https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-binary-using-native-package-management


function setup_k8s_repo_ubuntu_debian {
    sudo apt-get update && sudo apt-get install -y apt-transport-https
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
    echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
    sudo apt-get update
    sudo apt-get install -y kubectl
}


function setup_k8s_repo_centos_redhat_fedora {
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
}


function setup_k8s_kubectl_centos_redhat {
    yum install -y kubectl
}

function setup_k8s_kubectl_fedora {
    dnf install -y kubectl
}

function main {
    # Add the kubernetes CentOS/RedHat/Fedora repo
    setup_k8s_repo_centos_redhat_fedora
    # Install kubectl
    # setup_k8s_kubectl_centos_redhat
    setup_k8s_kubectl_fedora
}
