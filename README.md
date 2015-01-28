# vagrant-bsdpy
This is a basic Vagrant lab for testing and hacking on [BSDPy](https://bitbucket.org/bruienne/bsdpy), a Python NetBoot server. It is based on a Debian 7 (Wheezy) box.

It currently only supports (and assumes) NFS-shared NBIs. To be able to test this with other physical Macs, I configure a [public network interface](https://docs.vagrantup.com/v2/networking/public_network.html) in the Vagrantfile.

## Setup

Clone this repo:

`git clone --recursive https://github.com/timsutton/vagrant-bsdpy`

Put NBIs in the `nbi` directory.

Bring up the VM:

`vagrant up`

This has been tested to work with both the default VirtualBox providers and the HashiCorp VMware providers. Specify the provider using the `--provider` option or by setting the `VAGRANT_DEFAULT_PROVIDER` environment variable.

This will provision the VM and rsync over the contents of the NBI directory. The `rsync` synced folders are used as opposed to the VM providers' shared folder mechanism, because of issues using Linux's kernel NFS server on these shared folder filesystems.

When it's done, start the server. In this example, I'm listening on the `eth1` device (which is a bridged public interface), and specifying the NFS protocol.

`vagrant ssh -c "sudo /vagrant/bsdpy/bsdpserver.py --iface eth1 --proto nfs"`

You can tail the logfile also:

`vagrant ssh -c "tail -f /var/log/bsdpserver.log"`
