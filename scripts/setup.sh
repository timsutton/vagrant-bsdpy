#!/bin/sh

apt-get update
apt-get upgrade -y
apt-get install -y \
  build-essential \
  nfs-kernel-server \
  nginx \
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

# Nginx config
rm -f /etc/nginx/sites-enabled/default
cat > /etc/nginx/sites-available/bsdpy << EOF
server {
    listen       80;
    server_name  localhost;
    location / {
        root   /nbi;
    }
}
EOF
ln -sf /etc/nginx/sites-available/bsdpy /etc/nginx/sites-enabled/bsdpy
service nginx reload

# BSDPy stuff
## pydhcplib
if ! python -c "import pydhcplib"; then
  echo "pydhcplib seems to be not installed, installing Pepijn Bruienne's patched fork.."
  wget https://github.com/bruienne/pydhcplib/archive/master.tar.gz
  tar -xzf master.tar.gz
  cd pydhcplib-master
  sudo python setup.py install
  cd .. && sudo rm -rf pydhcplib-master master.tar.gz
fi

## bsdpy
pip install docopt
