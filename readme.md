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

## Download the ephemery testnet config

```
mkdir testnet-all
cd testnet-all
```

Download the `testnet-all.tar.gz` file for the [latest release of the Ephemery testnet](https://github.
com/pk910/test-testnet-repo/releases) and then unzip inside this folder.
```
tar -xzf testnet-all.tar.gz
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

