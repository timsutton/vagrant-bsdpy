#!/bin/sh

apt-get update
apt-get upgrade -y
apt-get install -y \
  build-essential \
  git \
  nfs-kernel-server \
  python-dev \
  python-pip \
  tftpd-hpa

# TFTP config
## We explicitly refuse the blksize using the '-r' option, as some newer Mac
## models send this option and cause aborted connections
cat > /etc/default/tftpd-hpa << EOF
# /etc/default/tftpd-hpa
TFTP_USERNAME="tftp"
TFTP_DIRECTORY="/nbi"
TFTP_ADDRESS="0.0.0.0:69"
TFTP_OPTIONS="-r blksize"
RUN_DAEMON="yes"
EOF
service tftpd-hpa restart

# NFS config
echo "/nbi   *(async,ro,no_root_squash,no_subtree_check,insecure)" > /etc/exports
service nfs-kernel-server reload

# BSDPy stuff
## pydhcplib
if ! python -c "import pydhcplib"; then
  echo "pydhcplib seems to be not installed, installing Pepijn Bruienne's patched fork.."
  git clone https://github.com/bruienne/pydhcplib
  cd pydhcplib
  sudo python setup.py install
fi

## bsdpy
pip install docopt
