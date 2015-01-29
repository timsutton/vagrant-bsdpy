# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "chef/debian-7.8"

  config.vm.network "public_network", :mac => "000C29B8B597"

  # use rsync because running the kernel NFS server off a vmware
  # shared folder doesn't really work
  config.vm.synced_folder "./nbi", "/nbi", type: "rsync",

    # We set rsync args with two changes from Vagrant's defaults:
    # - not using --copy-links, because our nbi dir may include relative
    #   symlinks (created by DeployStudio), and we don't want to copy
    #   the entire file twice
    # - not using -z, because the data we're transmitting is mostly a single
    #   large file that's mostly compressed, so we speed up the transfer
    rsync__args: ["--verbose", "--archive", "--delete"],
    rsync__exclude: [".git/", ".DS_Store"]

  config.vm.provision "shell", path: "scripts/setup.sh"
end
