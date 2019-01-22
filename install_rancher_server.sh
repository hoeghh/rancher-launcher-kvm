echo "
apiVersion: v1
kind: ServiceAccount
metadata:
  name: tiller
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: tiller
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: tiller
    namespace: kube-system

" > tiller-rbac-config.yaml
kubectl create -f tiller-rbac-config.yaml

helm init --service-account tiller

sleep 15

helm repo add rancher-latest https://releases.rancher.com/server-charts/latest

helm install stable/cert-manager \
  --name cert-manager \
  --namespace kube-system

helm install rancher-latest/rancher \
  --name rancher \
  --namespace cattle-system \
  --set hostname=rancher.praqma.com
