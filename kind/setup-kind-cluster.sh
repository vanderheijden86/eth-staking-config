#!/usr/bin/env zsh
# Create the kind cluster
kind create cluster --config kind.yaml

# Install nginx ingress controller
kubectl apply -f nginx-ingress-deployment.yaml

### Install cert-manager
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.5.3/cert-manager.yaml

