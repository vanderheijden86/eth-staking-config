#!/bin/bash

function updateGethYamlsWithCustomGenesis() {

  local custom_genesis_file="testnet-bootstrap-generator/dist/genesis.json"

  # List of target YAML files
  local yaml_files=("eth-nodes/geth.yaml")

  # Read properties from genesis.json
  shanghaiTime=$(jq -r '.config.shanghaiTime' $custom_genesis_file)
  extraData=$(jq -r '.extraData' "$custom_genesis_file")
  mixHash=$(jq -r '.mixhash' "$custom_genesis_file")
  parentHash=$(jq -r '.parentHash' "$custom_genesis_file")
  timestamp=$(jq -r '.timestamp' "$custom_genesis_file")

  # Update properties in each target YAML file
  for yaml_file in "${yaml_files[@]}"; do
    if [ -f "$yaml_file" ]; then
      yq eval -i ".spec.genesis.forks.shanghaiTime = $shanghaiTime" "$yaml_file"
      yq eval -i ".spec.genesis.extraData = \"$extraData\"" "$yaml_file"
      yq eval -i ".spec.genesis.mixHash = \"$mixHash\"" "$yaml_file"
      yq eval -i ".spec.genesis.parentHash = \"$parentHash\"" "$yaml_file"
      yq eval -i ".spec.genesis.timestamp = \"$timestamp\"" "$yaml_file"
      echo "Properties have been updated in $yaml_file from genesis.json"
    else
      echo "File $yaml_file not found"
    fi
  done

}

function createTekuConfigMap() {

  # Read the contents of config.yaml
  config_contents=$(cat testnet-bootstrap-generator/dist/config.yaml)

  # Create the ConfigMap YAML file
  cat >eth-nodes/teku-beacon-configmap.yaml <<EOL
apiVersion: v1
kind: ConfigMap
metadata:
  name: teku-beacon
  namespace: eth-nodes
data:
  network-config.yaml: |
$(echo "$config_contents" | sed 's/^/    /')
EOL

  echo "Created teku-beacon-configmap.yaml"
}

# move over the needed parameters from the generated custom genesis.json to geth.yaml
updateGethYamlsWithCustomGenesis

# create the teku-beacon ConfigMap
createTekuConfigMap
