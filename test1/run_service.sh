# First run install_and_start.sh
# Initial setup
cd singnet
export GOPATH=`pwd`
export SINGNET_REPOS=${GOPATH}/src/github.com/singnet
export PATH=${GOPATH}/bin:${PATH}

# Download example service
cd $SINGNET_REPOS
git clone https://github.com/singnet/dnn-model-services.git
cd dnn-model-services/Services/gRPC/Basic_Template/

# Prepare metadata (payment address is the second ganache identity 0x3b2b3C2e2E7C93db335E69D827F3CC4bC2A2A2cB)

snet service metadata_init service/service_spec Example1 0x3b2b3C2e2E7C93db335E69D827F3CC4bC2A2A2cB
snet service metadata_set_fixed_price 0.1
snet service metadata_add_endpoints localhost:8080

# Create organization test1
snet organization  create testo -y 

# Register our service
snet service publish testo tests -y

# At this point we should start the daemon....
