#!/bin/bash

LB_IP=$1
[ "$LB_IP" ]
: ${LB_IP:="127.0.0.1"}

echo ""
echo -e "Adding helm repo for cert-manger & Rancher\n"
helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
helm repo add jetstack https://charts.jetstack.io
helm repo update

echo -e  " Creating namespace \n"
kubectl create namespace cert-manager
kubectl create namespace cattle-system

sleep 1
echo -e " Installing Cert Manger\n"

helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --version v1.2.0 \
  --set installCRDs=true

echo -e " Checking Rollout Status\n"
kubectl -n cert-manager rollout status deploy/cert-manager
echo ""
echo -e "Waiting for pods to initialize\n"
sleep 20

echo -e "Installing Rancher \n"
helm install rancher rancher-latest/rancher \
  --namespace cattle-system \
  --set hostname=rancher-${LB_IP}.nip.io
echo -e ""

echo -e "Getting Deployment Status\n"
kubectl -n cattle-system rollout status deploy/rancher
echo -e ""
kubectl -n cattle-system get deploy rancher
