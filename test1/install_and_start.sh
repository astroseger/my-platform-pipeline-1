
# Initial setup
mkdir -p singnet/src/github.com/singnet
cd singnet
mkdir log
export GOPATH=`pwd`
export SINGNET_REPOS=${GOPATH}/src/github.com/singnet
export PATH=${GOPATH}/bin:${PATH}

# Init and start IPFS
export IPFS_PATH=$GOPATH/ipfs
ipfs init
ipfs bootstrap rm --all
ipfs config Addresses.API /ip4/127.0.0.1/tcp/5002
ipfs config Addresses.Gateway /ip4/0.0.0.0/tcp/8081
ipfs daemon >$GOPATH/log/ipfs.log 2>&1 &

# Start ganache and migrate contract 
# (and prepare npm package with local address for MultiPartyEscrow and Registry)

cd $SINGNET_REPOS

git clone https://github.com/singnet/platform-contracts

cd platform-contracts
npm install
npm install ganache-cli
npm run-script compile
./node_modules/.bin/ganache-cli --mnemonic 'gauge enact biology destroy normal tunnel slight slide wide sauce ladder produce' >$GOPATH/log/ganache.log 2>&1 &
./node_modules/.bin/truffle migrate --network local 
npm run-script package-npm


# SNET-CLI
cd $SINGNET_REPOS

git clone https://github.com/singnet/snet-cli

cd snet-cli/blockchain/
# this trick set correct networks/*.json for Registry and MultiPartyEscrow
npm install -S $SINGNET_REPOS/platform-contracts/build/npm-module
cd ..
./scripts/blockchain install
pip3 install -e .

# Configure SNET-CLI for local work
snet 
cat >> ~/.snet/config << EOF
[network.local]
default_eth_rpc_endpoint = http://localhost:8545
EOF

sed -ie '/ipfs/,+2d' ~/.snet/config
cat >> ~/.snet/config << EOF
[ipfs]
default_ipfs_endpoint = http://localhost:5002
EOF


# Add first ganache identity to snet 
snet identity create snet-user key --private-key 0xc71478a6d0fe44e763649de0a0deb5a080b788eefbbcf9c6f7aef0dd5dbd67e0
snet identity snet-user

# switch to local network
snet network local


# DAEMON (Installation will fail because of Agent..)

cd $SINGNET_REPOS
git clone https://github.com/singnet/snet-daemon.git
cd snet-daemon

# Take last contracts from the master
pushd resources/blockchain
npm install -S $SINGNET_REPOS/platform-contracts/build/npm-module
popd

./scripts/install
./scripts/build linux amd64
