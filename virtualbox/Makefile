
include ../vars.mk

PROVIDER=virtualbox

include ../rules.mk



VMDK_PATH=$(HOME)/.vagrant.d/boxes/generic-VAGRANTSLASH-$(BASE_BOX_NAME)/$(BASE_BOX_VERSION)/$(PROVIDER)/generic-$(BASE_BOX_NAME)-virtualbox-disk001.vmdk

$(VMDK_PATH):
	vagrant box add \
	    --provider $(PROVIDER) \
	    --box-version $(BASE_BOX_VERSION) \
	    $(BASE_BOX)


ova/$(BOX_NAME).ova: $(VMDK_PATH)
	./make_ova.pl $(BOX_NAME) $(VMDK_PATH) ./ova/



build/$(BOX_NAME)_$(BOX_VERSION).box \
build/$(BOX_NAME)_$(BOX_VERSION).box.md5 \
 : ova/$(BOX_NAME).ova developer.rb info.json
	set -x && \
	export PKR_VAR_SOURCE_PATH=$< && \
	export PKR_VAR_OUTPUT_DIR=$(output_dir) && \
	export PKR_VAR_BOX_NAME=$(BOX_NAME) && \
	export PKR_VAR_BOX_VERSION=$(BOX_VERSION) && \
	packer validate $(packer_template) && \
	PACKER_LOG=1 packer build $(packer_template)

packer-build: build/$(BOX_NAME)_$(BOX_VERSION).box




