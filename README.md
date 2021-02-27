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
For using it, you need to download the Helm client and have it in your path.
```
vi install_rancher_server.sh
# Change the line with the hostname
# Add the hostname to your /etc/hosts on a worker node
```

Or provide the IP address of loadbalander as input argument when running the script and it will use it as host.
Hostname: i.e rancher-127.0.0.1.nip.io
```
cd scripts
./install_rancher_server.sh '127.0.0.1'
```
It will create a namespaces for cert-manger and rancher. Adds the repository for Rancher & Cert-Manger and installs them in their respective namespaces.
