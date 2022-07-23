# cits3007 ubuntu-vagrant-box

Packer scripts for building Ubuntu 20.04-based Vagrant boxes.
Published boxes are hosted at
<https://app.vagrantup.com/arranstewart/boxes/cits3007-ubuntu2004>.

## Build instructions

Requires that Hashicorp Packer, Hashicorp Vagrant, and an appropriate box provider
(e.g.  either libvirt or VirtualBox) be installed, plus:

- GNU make
- jq

`cd` into either the `virtualbox` or `libvirt` directories.
Then `make packer-build` will build a box ready for uploading to the Vagrant
cloud.

`make publish` will publish it; this requires you have a file called TOKEN
in the relevant directory (it can be a symlink), containing a Vagrant cloud
access token.

## Box usage

To use and `ssh` into a VirtualBox-based box:

```
$ vagrant init arranstewart/cits3007-ubuntu2004
$ vagrant up --provider=virtualbox
$ vagrant ssh
```

For a libvirt-based box, do the same but use `--provider=libvirt`.


