
include ../vars.mk

PROVIDER=libvirt

include ../rules.mk



QCOW_PATH=$(HOME)/.vagrant.d/boxes/generic-VAGRANTSLASH-$(BASE_BOX_NAME)/$(BASE_BOX_VERSION)/$(PROVIDER)/box.img

$(QCOW_PATH):
	vagrant box add \
	    --provider $(PROVIDER) \
	    --box-version $(BASE_BOX_VERSION) \
	    $(BASE_BOX)

.qcow_checksum.md5: $(QCOW_PATH)
	cat $(QCOW_PATH) | pv | md5sum | awk '{ print $$1; }' > $@

build/$(BOX_NAME)_$(BOX_VERSION).box \
build/$(BOX_NAME)_$(BOX_VERSION).box.md5 \
build/$(BOX_NAME)_$(BOX_VERSION).qcow2 \
		: $(QCOW_PATH) \
			developer.rb \
			info.json \
			.qcow_checksum.md5
	set -x && \
	export PKR_VAR_SOURCE_PATH=$< && \
	export PKR_VAR_SOURCE_MD5=`cat .qcow_checksum.md5` && \
	export PKR_VAR_OUTPUT_DIR=$(output_dir) && \
	export PKR_VAR_DISK_SIZE=`qemu-img info --output=json $(QCOW_PATH) | jq '.["virtual-size"]'` && \
	export PKR_VAR_BOX_NAME=$(BOX_NAME) && \
	export PKR_VAR_BOX_VERSION=$(BOX_VERSION) && \
	packer validate $(packer_template) && \
	PACKER_LOG=1 packer build $(packer_template)

packer-build: build/$(BOX_NAME)_$(BOX_VERSION).box




