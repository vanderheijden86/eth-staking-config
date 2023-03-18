#!/bin/bash

KEYSTORE_DIR="../keystores/assigned_data/teku-keys"
SECRET_DIR="../keystores/assigned_data/teku-secrets"

# Ensure both directories exist
if [ ! -d "$KEYSTORE_DIR" ]; then
  echo "Error: $KEYSTORE_DIR directory not found."
  exit 1
fi

if [ ! -d "$SECRET_DIR" ]; then
  echo "Error: $SECRET_DIR directory not found."
  exit 1
fi

# Loop through the keystores
for keystore in $KEYSTORE_DIR/*; do
  key_name=$(basename -s .json "$keystore")
  secret_file="${SECRET_DIR}/${key_name}.txt"

  # Check if the corresponding secret file exists
  if [ ! -f "$secret_file" ]; then
    echo "Warning: Skipping $key_name, secret file not found: $secret_file"
    continue
  fi

  # Create the Kubernetes secret
  short_key_name="${key_name:0:30}"
  kubectl -n eth-nodes create secret generic "$short_key_name" \
    --from-file=keystore="$keystore" \
    --from-file=password="$secret_file"

  echo "Created secret: $short_key_name
done
