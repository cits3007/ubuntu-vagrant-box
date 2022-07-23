
##
# you should `include` vars.mk before including this file,
# and define a variable `PROVIDER` (typically this will
# be set to either "virtualbox" or "libvirt").


.DELETE_ON_ERROR:

.PHONY: \
  clean \
  extra-clean \
  packer-build \
  publish

SHELL = bash


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


developer.rb \
info.json:
	../make_templates.pl

# publish to vagrant cloud
# assumes you've got a vagrant cloud token in a file
# called TOKEN
publish: build/$(BOX_NAME)_$(BOX_VERSION).box build/$(BOX_NAME)_$(BOX_VERSION).box.md5
	set -x && \
	  VAGRANT_CLOUD_TOKEN=`cat TOKEN` ../publish.sh \
	    build/$(BOX_NAME)_$(BOX_VERSION).box \
	    build/$(BOX_NAME)_$(BOX_VERSION).box.md5 \
            $(PROVIDER)

clean:
	-rm -rf .box* .version* .provider* .release* .upload* \
	    developer.rb \
	    info.json


extra-clean: clean
	-rm -rf build ova

