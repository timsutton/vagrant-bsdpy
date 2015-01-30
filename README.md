# vagrant-bsdpy
This is a basic Vagrant lab for testing and hacking on [BSDPy](https://bitbucket.org/bruienne/bsdpy), a Python NetBoot server written by [Pepijn Bruienne](http://enterprisemac.bruienne.com). It is based on a Debian 7 (Wheezy) box.

The default configuration is to use HTTP NBIs, but there is documentation in the Vagrantfile on how to configure synced folders for use with NFS NBIs. To be able to test this with other physical Macs, I configure a [public network interface](https://docs.vagrantup.com/v2/networking/public_network.html) in the Vagrantfile.

## Components

A NetBoot solution requires at least three services:

* [BSDP](http://en.wikipedia.org/wiki/Boot_Service_Discovery_Protocol), implemented with BSDPy.
* TFTP, implemented with [TFTPD-HPA](http://chschneider.eu/linux/server/tftpd-hpa.shtml).
* NFS or HTTP for serving the actual boot image. This project uses the NFS kernel server, and Nginx for HTTP.

There is no vanilla DHCP solution included in this project. Clients will need to be able to acquire an IP address at boot time from elsewhere.

## Setup

Clone this repo and the included BSDPy submodule:

`git clone --recursive https://github.com/timsutton/vagrant-bsdpy`

Put NBIs in the `nbi` directory.

Bring up the VM:

`vagrant up`

This has been tested to work with both the default VirtualBox providers and the HashiCorp VMware providers. Specify the provider using the `--provider` option or by setting the `VAGRANT_DEFAULT_PROVIDER` environment variable.

This will provision the VM and set up the shared folder.

When it's done, start the server. In this example, I'm listening on the `eth1` device (which is a bridged public interface):

`vagrant ssh -c "sudo /vagrant/bsdpy/bsdpserver.py --iface eth1"`

Alternatively, specifying I will be serving NBIs over NFS:

`vagrant ssh -c "sudo /vagrant/bsdpy/bsdpserver.py --iface eth1 --proto nfs"`

You can also tail the logfile:

`vagrant ssh -c "tail -f /var/log/bsdpserver.log"`

If you are using rsync synced folders, don't forget to sync any changes you make to NBIs:

`vagrant rsync`

or have Vagrant poll for changes:

`vagrant rsync-auto`
