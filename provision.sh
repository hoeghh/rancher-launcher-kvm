#!/bin/bash
source provision.vars

add_node_to_cluster() {
  local VM_IP=$((110 + $1))

  echo "    - address: "192.168.122.$VM_IP"
      user: rke
      ssh_key_path: ~/.ssh/id_rsa
      role:
        - controlplane
        - etcd
        - worker" >> cluster.yml
}

create_vm () {
  local VM_NB=$1
  local VM_KS="ks-$VM_NB.cfg"
  local VM_IP=$((110 + $VM_NB))
  local VM_PORT=$((5900 + $VM_NB))

  echo "Using port $VM_PORT"

  echo "Cleaning up old kickstart file..."
  rm -f $VM_KS

  echo "Creating new ks.cfg file..."
  cp ks.cfg.template $VM_KS
  sed -i 's/TMPL_PSWD/praqma/g' $VM_KS
  sed -i 's/TMPL_HOSTNAME/'$vm_prefix-$VM_NB'/g' $VM_KS
  sed -i 's/TMPL_IP/192.168.122.'$VM_IP'/g' $VM_KS
  sed -i "s;TMPL_SSH_KEY;$SSH_KEY;g" $VM_KS

  echo "Creating disc image..."
  qemu-img create -f qcow2 $image_location/$vm_prefix-$VM_NB.qcow2 $vm_disc_size

  echo "Creating virtual machine and running installer..."
  virt-install --name $vm_prefix-$VM_NB \
    --description $vm_description-$VM_NB \
    --ram $vm_ram \
    --vcpus $vm_vcpu \
    --disk path=/vm-disks/$vm_prefix-$VM_NB.qcow2,size=15 \
    --os-type linux \
    --os-variant $vm_variant \
    --network bridge=virbr0 \
    --graphics vnc,listen=127.0.0.1,port=$VM_PORT \
    --location $vm_iso \
    --noautoconsole \
    --initrd-inject $VM_KS --extra-args="ks=file:/$VM_KS" 

}

# Check if ssh keys exists
if [ -f ~/.ssh/id_rsa.pub ]; then
  SSH_KEY=$(cat ~/.ssh/id_rsa.pub)
else
  echo "Public key not found. It will be left black..."
  SSH_KEY=""
fi

# Check if no input, then set number of servers to 1
SRV_NB=$1
if [ -z "$SRV_NB" ]; then
  SRV_NB=1
fi

echo "cluster_name: $k8s_name" > cluster.yml
echo "k8s_version\" $k8s_version\"" >> cluster.yml

echo "" >> hosts_entries

echo "nodes:" >> cluster.yml
echo "Creating $SRV_NB of servers..."

for i in $( seq 1 $SRV_NB )
do
  echo "Creating VM $i"
  create_vm $i & 
  add_node_to_cluster $i
  echo "192.168.122.$((110 + $i)) $vm_prefix-$i" >> hosts_entries
done

# Wait for machine commands to finish
wait

# add network plugin
echo "
network:
    plugin: $k8s_network" >> cluster.yml


# Disable build in Nginx ingress if needed
if [ $k8s_ingress == "fase" ]; then
  echo "ingress:
      provider: none" >> cluster.yml
fi

echo "Add these entries to your hosts /etc/hosts"
cat hosts_entries
