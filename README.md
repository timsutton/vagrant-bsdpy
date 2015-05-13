# vagrant-bsdpy
This is a basic Vagrant lab for testing and hacking on [BSDPy](https://bitbucket.org/bruienne/bsdpy), a Python NetBoot server written by [Pepijn Bruienne](http://enterprisemac.bruienne.com). It is based on a Debian 8 (Jessie) box that supports both the `virtualbox` and `vmware_fusion` providers.

The default configuration is to use HTTP NBIs, but there is documentation in the Vagrantfile on how to configure synced folders for use with NFS NBIs. To be able to test this with other physical Macs, I configure a [public network interface](https://docs.vagrantup.com/v2/networking/public_network.html) in the Vagrantfile.

## Components

A NetBoot solution requires at least three services:

* [BSDP](http://en.wikipedia.org/wiki/Boot_Service_Discovery_Protocol), implemented with BSDPy.
* TFTP, implemented with [TFTPD-HPA](http://chschneider.eu/linux/server/tftpd-hpa.shtml).
* NFS or HTTP for serving the actual boot image. This project uses the NFS kernel server, and Nginx for HTTP.

There is no vanilla DHCP solution included in this project. Clients will need to be able to acquire an IP address at boot time from elsewhere.

This project manages the BSDPy process using [runit](http://smarden.org/runit). Josh Timberman has a [great blog post](http://jtimberman.housepub.org/blog/2012/12/29/process-supervision-solved-problem) on this.

## Setup

Clone this repo:

```
git clone https://github.com/timsutton/vagrant-bsdpy
```

Clone BSDPy from a branch/source of your choosing within the repo:

```
cd vagrant-bsdpy
git clone https://bitbucket.org/bruienne/bsdpy
```

Put NBIs in the `nbi` directory.

Bring up the VM:

`vagrant up`

This has been tested to work with both the default VirtualBox providers and the HashiCorp VMware providers. Specify the provider using the `--provider` option or by setting the `VAGRANT_DEFAULT_PROVIDER` environment variable.

This will provision the VM and set up the shared folder. At this point the BSDPy service should be running. You can also tail the logfile to view progress:

`vagrant ssh -c "tail -f /var/log/bsdpserver.log"`

## Runit config

The process will be started with the `run` script located at `/etc/sv/bsdpy/run`. This script is built when Vagrant provisions the machine, and the arguments can be customized by setting the `BSDPSERVER_ARGS` constant at the top of the Vagrantfile.

Use `sv` to manage the service:

```
sv restart bsdpy
sv stop bsdpy
sv start bsdpy
sv 1 bsdpy (send a USR1 signal to have BSDPy rescan images)
```

You can also use typical init-style commands like `service restart bsdpy`.

## Rsync

If you are using rsync synced folders (which might be the case if BSDPy is configured to point clients to NFS), don't forget to sync any changes you make to NBIs:

`vagrant rsync`

or have Vagrant poll for changes:

`vagrant rsync-auto`
