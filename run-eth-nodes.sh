#!/bin/bash

# Set the path to your local-testnet-bootstrap folder
LOCAL_TESTNET_BOOTSTRAP_PATH="/Users/andrevanderheijden/Documents/eth-staking/eth-staking-config/local-testnet-bootstrap"

# Set the path to your Kubernetes manifest file
KUBE_MANIFEST_PATH="eth-nodes/clc-checkpoint-sync-server.yaml"

copy_local_testnet_bootstrap_to_kind_node_container() {
  # Find the kind node container name
  KIND_NODE_CONTAINER_NAME=$(docker ps --format '{{.Names}}' -f name=kind | head -n 1)

  if [ -z "$KIND_NODE_CONTAINER_NAME" ]; then
    echo "No kind node container found. Make sure your kind cluster is running."
    exit 1
  fi

  # Copy the local-testnet-bootstrap folder to the kind node container
  docker cp "$LOCAL_TESTNET_BOOTSTRAP_PATH" "$KIND_NODE_CONTAINER_NAME":/local-testnet-bootstrap

  echo "Successfully copied the local-testnet-bootstrap folder to the kind node container."
}

replace_node_name() {
  local manifest_path="$1"
  local node_name="$2"

  if [ -f "$manifest_path" ]; then
    sed -i.bak "s/<NODE_NAME>/$node_name/g" "$manifest_path"
    rm "${manifest_path}.bak"
    echo "Replaced <NODE_NAME> with $node_name in $manifest_path"
  else
    echo "Kubernetes manifest file not found at $manifest_path"
  fi
}

# Sets the GENESIS_TIMESTAMP property in the values.env file to the current Unix timestamp
# plus a specified offset in seconds.
# Usage: set_genesis_timestamp <offset_in_seconds>
function set_genesis_timestamp {
    local offset=$1
    local target_file="../test-testnet-repo/values.env"

    if [[ -z "$offset" ]]; then
        echo "Please provide an offset in seconds."
        return 1
    fi

    if [[ ! -f "$target_file" ]]; then
        echo "Target file $target_file does not exist."
        return 1
    fi

    local current_timestamp=$(date +%s)
    local new_timestamp=$((current_timestamp + offset))

    if grep -q '^export GENESIS_TIMESTAMP=' "$target_file"; then
        sed -i.bak "s/^export GENESIS_TIMESTAMP=.*/export GENESIS_TIMESTAMP=$new_timestamp/" "$target_file" \
        && rm -f "${target_file}.bak"
    else
        echo "export GENESIS_TIMESTAMP=$new_timestamp" >> "$target_file"
    fi

    echo "GENESIS_TIMESTAMP updated to $new_timestamp in $target_file"
}

# Sets the GENESIS_TIMESTAMP property in the values.env file to now + 10 minutes
set_genesis_timestamp 600

# run the build-genesis.sh script from the test-testnet-repo and return to here
rm -rf ../test-testnet-repo/dist
cd ../test-testnet-repo && bash scripts/build-genesis.sh && cd -
cp ../test-testnet-repo/dist/genesis.ssz ../eth-staking-config/local-testnet-bootstrap/genesis.ssz



# Copy the local-testnet-bootstrap folder to the kind node container
copy_local_testnet_bootstrap_to_kind_node_container

# Replace <NODE_NAME> with the Kubernetes node name in the manifest file
replace_node_name "$KUBE_MANIFEST_PATH" "$KIND_NODE_CONTAINER_NAME"
