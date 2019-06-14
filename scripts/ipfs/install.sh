# Install IPFS Binary
# Command: curl https://scripts.barajs.dev/ipfs/install.sh | bash -s -- <version|optional>
# Command: curl https://scripts.barajs.dev/ipfs/install.sh | bash -s -- "v0.4.21"

version=$1
IPFS_VERSION=${version:-"v0.4.21"}
IPFS_BIN="go-ipfs_${IPFS_VERSION}_linux-386.tar.gz"
wget https://github.com/ipfs/go-ipfs/releases/download/$IPFS_VERSION/$IPFS_BIN && \
tar xvfz $IPFS_BIN && \
sudo mv go-ipfs/ipfs /usr/local/bin/ipfs && \
rm -rf go-ipfs $IPFS_BIN

echo "GO-IPFS ${IPFS_VERSION} installed!"
