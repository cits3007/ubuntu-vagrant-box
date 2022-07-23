# cits3007 ubuntu-vagrant-box

Packer scripts for building Ubuntu 20.04-based Vagrant boxes.

Requires Hashicorp Vagrant and an appropriate box provider (e.g.
either libvirt or VirtualBox) be installed, plus common Unix
commands.

`make packer-build` will build a box ready for uploading to the
Vagrant cloud, and `make publish` will publish it.

## Usage

To use and `ssh` into a VirtualBox-based box:

```
$ vagrant init arranstewart/cits3007-ubuntu2004
$ vagrant up --provider=virtualbox
$ vagrant ssh
```


