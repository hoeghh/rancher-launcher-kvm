# https://rancher.com/docs/rke/v0.1.x/en/etcd-snapshots/
rke etcd snapshot-save --name production --config cluster.yml
scp rke@192.168.122.111:/opt/rke/etcd-snapshots/production .
