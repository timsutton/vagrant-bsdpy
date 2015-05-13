# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "kikitux/jessie"
  config.vm.network "public_network", :mac => "000C29B8B597"

  # Set this to the arguments you want passed to bsdpserver.py
  # 'eth1' is used here because this is the public interface defined above
  BSDPSERVER_ARGS = "--iface eth1 --proto http"

  # Synced folder config
  # NetBoot images can be served via either HTTP or NFS (BSDPy currently
  # supports one or the other in a given instance).
  #
  # It's expected that NBIs can be found in the VM at /nbi, and so a synced
  # folder is configured to share the 'nbi' directory in this repo.
  # The default is to use HTTP, which uses nginx to serve a host from the
  # /nbi root.
  config.vm.synced_folder "./nbi", "/nbi"

  # If you instead run BSDPy with `--proto nfs`, you may need
  # to use an alternate synced folder mechanism. With the `vmware_fusion`
  # provider, the NFS kernel server is not able to export vmhgfs-mount volumes.
  # I've tested that the "nfs" synced folder type works, as does the "rsync"
  # type. Rsync type obviously adds more time and disk space requirements,
  # and requires additional arguments to work properly.
  # See the commented options below for these other synced_folder types:

  # config.vm.synced_folder "./nbi", "/nbi", type: "nfs"
  # config.vm.synced_folder "./nbi", "/nbi", type: "rsync",
    # We set rsync args with two changes from Vagrant's defaults:
    # - not using --copy-links, because our nbi dir may include relative
    #   symlinks (created by DeployStudio), and we don't want to copy
    #   the entire file twice
    # - not using -z, because the data we're transmitting is mostly a single
    #   large file that's mostly compressed, so we speed up the transfer
    # rsync__args: ["--verbose", "--archive", "--delete"],
    # rsync__exclude: [".git/", ".DS_Store"]

  config.vm.provision "shell", path: "scripts/setup.sh",
    args: "#{BSDPSERVER_ARGS}"
end
