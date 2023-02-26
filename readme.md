# Eth staking docs

---
## Bootstrapping the secrets
This part of the documentation only needs to be run once, and it's only needed if you want to generate fresh secrets 
and not if you already have them.

---
### Generating a node key for eth clients

You can use the bootnode utility for this to create a nodekey immediately 
after geth init. You can download it with "Geth & Tools" from https://geth.ethereum.org/downloads/

```bash
bootnode -genkey nodekey
```    

You then copy the contents of the generated nodekey file to the node-key-secret.yaml file. 

### Generating a jwt secret for eth clients

```bash
openssl rand -hex 32 | tr -d "\n"
```    

You then copy the this secret to the jwt-secret.yaml file.

## Configure ethereum nodes to connect to the Ephemery testnet config

Download the `testnet-all.tar.gz` file for the [latest release of the Ephemery testnet](https://github.com/pk910/test-testnet-repo/releases) and then unzip inside this folder.

```bash
mkdir testnet-all
cd testnet-all
tar -xzf testnet-all.tar.gz
```

---
#### Geth

Then from these files you use the following values to configure geth in `geth-kotal.yaml`: 

For `{bootnodes}` look in ~/testnet-all/boot_enode.txt. Entries must be separated,by,commas and "enclosed in quotes",
like:

```yaml
bootnodes:
  - enode://0f2c301a9a3f9fa2ccfa362b79552c052905d8c2982f707f46cd29ece5a9e1c14ecd06f4ac951b228f059a43c6284a1a14fce709e8976cac93b50345218bf2e9@135.181.140.168:30343
```

For `{networkID}` look for `chainId` in ~/testnet-all/genesis.json and place it like this in `geth-kotal.yaml`:

```yaml
genesis:
  networkId: 39438064
```

---
#### Teku

For `teku-kotal.yaml` you can use the following values:

```yaml
checkpointSyncUrl: "https://github.com/pk910/test-testnet-repo/releases/download/ephemery-64/genesis.ssz"
```

For `{bootnodes}` look in ~/testnet-all/boot_enr.txt. Entries must be separated,by,commas and "enclosed in quotes". 
In your `teku-kotal.yaml` you cannot add this yet, as Kotal doesn't support it yet. In a direct Teku config it is 
be added like this flag to the teku command:

```bash
--p2p-discovery-bootnodes {bootnodes}
```

Network would be added like this
```bash
--network ~/testnet-all/config.yaml \
```


## Running the eth clients

```bash
kubectl apply -f eth-nodes/.
```
You will see output like this:
```bash
namespace/eth-nodes created
node.ethereum.kotal.io/geth-node created
secret/jwt-secret configured
secret/geth-nodekey configured
```

