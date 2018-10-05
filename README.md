# rancher-launcher-kvm
A easy way to get a Rancher Kubernetes cluster up and running on KVM/Libvirt

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

When done, a cluster will be running. It will generate a config file you can use with kubeadm.

```
kubectl get cs --kubeconfig kube_config_cluster.yml
```
