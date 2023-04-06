#!/bin/bash


# Sets the GENESIS_TIMESTAMP property in the values.env file to the current Unix timestamp
# plus a specified offset in seconds.
# Usage: set_genesis_timestamp <offset_in_seconds>
function set_genesis_timestamp {
   local offset=$1
   local target_file="testnet-bootstrap-generator/values.env"


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


# Sets the GENESIS_TIMESTAMP property in the values.env file to now specified offset in seconds
set_genesis_timestamp 600


# run the build-genesis.sh script from the testnet-bootstrap-generator and return to here
rm -rf testnet-bootstrap-generator/dist
cd testnet-bootstrap-generator && bash scripts/build-genesis.sh && cd -
