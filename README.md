# vagrant-bsdpy
This is a basic Vagrant lab for testing and hacking on [BSDPy](https://bitbucket.org/bruienne/bsdpy), a Python NetBoot server written by [Pepijn Bruienne](http://enterprisemac.bruienne.com). It is based on a Debian 7 (Wheezy) box.

It currently only supports (and assumes) NFS-shared NBIs. To be able to test this with other physical Macs, I configure a [public network interface](https://docs.vagrantup.com/v2/networking/public_network.html) in the Vagrantfile.

## Components

A NetBoot solution requires at least three services:

* [BSDP](http://en.wikipedia.org/wiki/Boot_Service_Discovery_Protocol), implemented with BSDPy.
* TFTP, implemented with [TFTPD-HPA](http://chschneider.eu/linux/server/tftpd-hpa.shtml).
* NFS or HTTP for serving the actual boot image. This project uses the NFS kernel server, and does not implement HTTP.

There is no vanilla DHCP solution included in this project. Clients will need to be able to acquire an IP address at boot time from elsewhere.

## Setup

Clone this repo:

`git clone --recursive https://github.com/timsutton/vagrant-bsdpy`

Put NBIs in the `nbi` directory.

Bring up the VM:

`vagrant up`

This has been tested to work with both the default VirtualBox providers and the HashiCorp VMware providers. Specify the provider using the `--provider` option or by setting the `VAGRANT_DEFAULT_PROVIDER` environment variable.

This will provision the VM and rsync over the contents of the NBI directory. The `rsync` synced folders are used as opposed to the VM providers' shared folder mechanism, because of issues using Linux's kernel NFS server on these shared folder filesystems.

When it's done, start the server. In this example, I'm listening on the `eth1` device (which is a bridged public interface), and specifying the NFS protocol:

`vagrant ssh -c "sudo /vagrant/bsdpy/bsdpserver.py --iface eth1 --proto nfs"`

You can also tail the logfile:

`vagrant ssh -c "tail -f /var/log/bsdpserver.log"`

When you make updates to an NBI, you can sync them over manually:

`vagrant rsync`

or have Vagrant poll for changes:

`vagrant rsync-auto`
