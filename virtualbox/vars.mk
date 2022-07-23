
# version being built

BOX_VERSION=0.1.0

AUTHOR="Arran Stewart"

# packer config file to use
#PACKER_FILE=dokku.pkr.hcl

# input box to use
BASE_BOX_NAME=ubuntu2004
BASE_BOX=generic/$(BASE_BOX_NAME)
BASE_BOX_VERSION=4.1.0

VMDK_PATH=$(HOME)/.vagrant.d/boxes/generic-VAGRANTSLASH-$(BASE_BOX_NAME)/$(BASE_BOX_VERSION)/virtualbox/generic-$(BASE_BOX_NAME)-virtualbox-disk001.vmdk

# name for our built box
BOX_NAME=cits3007-ubuntu2004

VAGRANT_CLOUD_USERNAME=arranstewart

SHORT_DESCRIPTION=gcc and GNU make on Ubuntu 20.04

GITHUB_REPO=https://github.com/cits3007/ubuntu-vagrant-box

# markdown fragment
DESCRIPTION="gcc and GNU make on Ubuntu 20.04\n\nBuilt from github repo at $(GITHUB_REPO)"


