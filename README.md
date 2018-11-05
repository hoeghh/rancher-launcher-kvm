# Rancher launcher kvm
A easy way to get a Rancher Kubernetes cluster up and running on KVM/Libvirt

> This project is sponsored by Praqma.com

This script will create machines in KVM prepared with docker and ssh key. It will also generate a cluster.yml that can be used by RKE to provision a Kubernetes cluster. This cluster can then be joined to a Rancher manager UI.

Create 3 nodes by running 
```
./provision.sh 3
```

You will end up with 3 virtual machines having a user named rke with the SSH keys found in ~/.ssh/ on your host. Also, a cluster.yml will be generated.

By default, all nodes will be running etcd, controlplane and worker containers. Edit cluster.yml to change this to your liking. 

Then, simply run rke to create the cluster

```
rke up
```

When done, a cluster will be running. It will generate a config file you can use with kubectl.

```
kubectl get cs --kubeconfig kube_config_cluster.yml
```

# Install Rancher UI
I made a small script that installs the Rancher Server (UI) via Helm.
Fore using it, you need to download the Helm client and have it in your path.
```
vi install_rancher_server.sh
# Change the last line with the hostname
# Add the hostname to your /etc/hosts on a worker node

./install_rancher_server.sh
```
It will create a ServiceAccound for Tiller and a ClusterRoleBinding for this ServiceAccount to a ClusteRole called cluster-admin. Then it installs Tiller, adds the repository for Rancher Server and installs Rancher and cert-manager.
