
.DELETE_ON_ERROR:

.PHONY: packer-build

SHELL = bash

include vars.mk

packer_template = ./ubuntu_box.pkr.hcl
output_dir=build

default:
	echo pass

print_box_name:
	@echo $(BOX_NAME)

print_box_version:
	@echo $(BOX_VERSION)

print_author:
	@echo $(AUTHOR)

print_short_desc:
	@echo '$(SHORT_DESCRIPTION)'

print_desc:
	@printf '%s' $(DESCRIPTION)

print_vagrant_cloud_username:
	@printf '%s' $(VAGRANT_CLOUD_USERNAME)

print_github_repo:
	@printf '%s' $(GITHUB_REPO)



$(VMDK_PATH):
	vagrant box add \
	    --provider virtualbox \
	    --box-version $(BASE_BOX_VERSION) \
	    $(BASE_BOX)


ova/$(BOX_NAME).ova: $(VMDK_PATH)
	./make_ova.pl $(BOX_NAME) $(VMDK_PATH) ./ova/

developer.rb \
info.json:
	./make_templates.pl

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

# publish to vagrant cloud
# assumes you've got a vagrant cloud token in a file
# called TOKEN
publish: build/$(BOX_NAME)_$(BOX_VERSION).box build/$(BOX_NAME)_$(BOX_VERSION).box.md5
	set -x && \
	  VAGRANT_CLOUD_TOKEN=`cat TOKEN` ./publish.sh \
	    build/$(BOX_NAME)_$(BOX_VERSION).box \
	    build/$(BOX_NAME)_$(BOX_VERSION).box.md5

clean:
	-rm -rf .box* .version* .provider* .release* .upload*

extra-clean: clean
	-rm -rf build ova

