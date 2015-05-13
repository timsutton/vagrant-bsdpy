#!/bin/sh

bsdpyserver_opts="$@"
echo "Setting up VM with BSDPy options: ${bsdpyserver_opts}"
apt-get update
apt-get upgrade -y
apt-get install -y \
  build-essential \
  nfs-kernel-server \
  nginx \
  python-dev \
  python-pip \
  runit \
  tftpd-hpa

# TFTP config
## We explicitly force a specific block size. 1468 is known to work with the
## 2015 12" Macbook and USB-C -> USB -> USB Ethernet adapters.
## https://twitter.com/bruienne/status/598521812859883520
cat > /etc/default/tftpd-hpa << EOF
# /etc/default/tftpd-hpa
TFTP_USERNAME="tftp"
TFTP_DIRECTORY="/nbi"
TFTP_ADDRESS="0.0.0.0:69"
TFTP_OPTIONS="-B 1468"
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
# add some additional logging
echo "error_log /var/log/nginx/error.log notice;" > /etc/nginx/conf.d/log_notice.conf
# enable the bsdpy site
ln -sf /etc/nginx/sites-available/bsdpy /etc/nginx/sites-enabled/bsdpy
service nginx restart

# BSDPy stuff
## pydhcplib module (with a native extension)
if ! python -c "import pydhcplib"; then
  echo "pydhcplib seems to be not installed, installing Pepijn Bruienne's patched fork.."
  wget https://github.com/bruienne/pydhcplib/archive/master.tar.gz
  tar -xzf master.tar.gz
  cd pydhcplib-master
  sudo python setup.py install
  cd .. && sudo rm -rf pydhcplib-master master.tar.gz
fi

## Install BSDPy requirements (docopt, requests)
pip install -r /vagrant/bsdpy/requirements.txt

# Runit service config for BSDPy
## set up our service directory, run script
[ ! -d /etc/sv/bsdpy ] && mkdir /etc/sv/bsdpy
cat > /etc/sv/bsdpy/run << EOF
#!/bin/sh
exec chpst /vagrant/bsdpy/bsdpserver.py ${bsdpyserver_opts}
EOF
chmod 700 /etc/sv/bsdpy/run
## symlink it to enable it
ln -sf /etc/sv/bsdpy /etc/service/bsdpy
## symlink sv to an init.d service for init usage compatibility
ln -sf /usr/bin/sv /etc/init.d/bsdpy
sv start bsdpy
