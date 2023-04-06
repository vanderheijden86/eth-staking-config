#!/bin/bash

# Set the path to your local-testnet-bootstrap folder
LOCAL_TESTNET_BOOTSTRAP_PATH="testnet-bootstrap-generator/dist"

# Set the path to your Kubernetes manifest file
KUBE_MANIFEST_PATH="eth-nodes/clc-checkpoint-sync-server.yaml"

# Find the kind node container name
KIND_NODE_CONTAINER_NAME=$(docker ps --format '{{.Names}}' -f name=kind-worker2 | head -n 1)

copy_local_testnet_bootstrap_to_kind_node_container() {

  if [ -z "$KIND_NODE_CONTAINER_NAME" ]; then
    echo "No kind node container found. Make sure your kind cluster is running."
    exit 1
  fi

  # First, remove the existing local-testnet-bootstrap folder from the Kind node container, if it exists:
  docker exec "$KIND_NODE_CONTAINER_NAME" rm -rf /local-testnet-bootstrap

  # Copy the local-testnet-bootstrap folder to the kind node container
  docker cp "$LOCAL_TESTNET_BOOTSTRAP_PATH" "$KIND_NODE_CONTAINER_NAME":/local-testnet-bootstrap

  echo "Successfully copied the local-testnet-bootstrap folder to the kind node container."
}

replace_node_name() {
  local manifest_path="$1"
  local node_name="$2"

  echo "$node_name"

  if [ -f "$manifest_path" ]; then
    sed -i.bak "s/<NODE_NAME>/$node_name/g" "$manifest_path"
    rm "${manifest_path}.bak"
    echo "Replaced <NODE_NAME> with $node_name in $manifest_path"
  else
    echo "Kubernetes manifest file not found at $manifest_path"
  fi
}

# Copy the local-testnet-bootstrap folder to the kind node container
copy_local_testnet_bootstrap_to_kind_node_container

# Replace <NODE_NAME> with the Kubernetes node name in the manifest file
replace_node_name "$KUBE_MANIFEST_PATH" "$KIND_NODE_CONTAINER_NAME"
