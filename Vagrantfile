# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "chef/debian-7.8"

  config.vm.network "public_network", :mac => "000C29B8B597"

  # use rsync because running the kernel NFS server off a vmware
  # shared folder doesn't really work
  config.vm.synced_folder "./nbi", "/nbi", type: "rsync",
    # only change here from Vagrant defaults is we use --links instead of
    # --copy-links, because our nbi dir may include relative
    rsync__args: ["--verbose", "--archive", "--delete", "-z"],
    rsync__exclude: ".git/"

  config.vm.provision "shell", path: "scripts/setup.sh"
end

# start the server:
# vagrant ssh -c "sudo /vagrant/bsdpy/bsdpserver.py --iface eth1 --proto nfs"
# tail the log:
# vagrant ssh -c "tail -f /var/log/bsdpserver.log"
