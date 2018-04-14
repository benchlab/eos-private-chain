#################################################################################
###  EOS Custom Blockchain Script For Localhost Testnet
###  BenchLabs / Jared Rice Sr.
###  WARNING - THIS IS NOT A BASH SCRIPT :)
#################################################################################

###########################
### Create The Initial Blockchain host
###########################

git clone https://github.com/EOSIO/eos --recursive
git submodule update --init --recursive
cd eos && ./eosio_build.sh
cd build && make test
cd build && sudo make install

cd ../programs
screen
keosd --http-server-address 127.0.0.1:8899

### exit screen with Ctrl-a d or Ctrl-a Ctrl-d

./cleos --wallet-port 8899  wallet create

### uses "default" name for initial node producer. This node will later control the BIOS of your chain and resource allocation

./nodeos --enable-stale-production --producer-name default --plugin eosio::chain_api_plugin --plugin eosio::net_api_plugin

###  make sure your blockchain genesis has been generated. If you don't have this file, you can do so here: 
###  https://eosio.github.io/genesis/

###  set BIOS contract from the network on your second node
./cleos --wallet-port 8899 set contract eosio build/contracts/eosio.bios

### exit screen with Ctrl-a d or Ctrl-a Ctrl-d and go to a second terminal window on {HOST} to start our BIOS producer

###########################
### Enabling Host As BIOS Producer
###########################

./nodeos --enable-stale-production --producer-name eosio --plugin eosio::chain_api_plugin --plugin eosio::net_api_plugin


###########################
### Install for 1st Node - should be a separate machine for proper testing
### EOS Must Be Installed On Each Separate Node. Not The Case For A TestNet on the Same Machine
###########################

git clone https://github.com/EOSIO/eos --recursive
git submodule update --init --recursive
cd eos && ./eosio_build.sh
cd build && make test
cd build && sudo make install
screen

cd ../programs

###  We already have the default account running on Node #1, so we will create a custom account on Node #2
###  This will generate a public/private keypair for an EOS network

./cleos create key

###  Now we need to import that key into the cleos wallet utility.

./cleos --wallet-port 8899 wallet import [private-key-here]

###  Create an account by defining the name, in this case "stan", along with the keypair generated with the "create key" command a few steps ago.

./cleos --wallet-port 8899 create account eosio stan [public-key]

### exit screen with Ctrl-a d or Ctrl-a Ctrl-d and go to a fourth terminal window to start our first block producing node

###########################
### Converting 1st Node Into Block Producer
###########################

###  Now we setup our second node as a block producer and load a few plugins as well as setting the configuration settings for the block producing node.
./nodeos --producer-name eosio --plugin eosio::chain_api_plugin \
--plugin eosio::net_api_plugin \
--http-server-address 127.0.0.1:8899 \
--p2p-listen-endpoint 127.0.0.1:9877 \
--p2p-peer-address 127.0.0.1:9876 \
--config-dir chain-node-2 \
--data-dir chain-node-2  \
--private-key [\"stan-public-key\",\"stan-private-key\"]


###########################
### SetProds For 1st Node (Block Producer)(Command must be ran on the BIOS HOST)
###########################

./cleos --wallet-port 8899 push action eosio setprods "{ \"version\": 1, \"producers\": [{\"producer_name\": \"stan\",\"block_signing_key\": \"public-key-for-stan\"}]}" -p


###########################
### Test Network From BIOS Host
###########################

### Get info from overall network
./cleos get info 

###  Get info from the 1st Node
./cleos --port 8889 get info
