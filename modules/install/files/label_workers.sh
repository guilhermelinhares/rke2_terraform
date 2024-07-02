#!/bin/bash 
NODE="${1}"
KUBECONFIG="${2}"

kubectl --kubeconfig=$KUBECONFIG label node $NODE node-role.kubernetes.io/worker=worker