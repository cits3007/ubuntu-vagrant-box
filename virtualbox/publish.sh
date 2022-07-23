#!/usr/bin/env bash

# script to publish box to vagrant cloud.
# adapted from
# https://github.com/sdorsett/packer-centos7-esxi/blob/cb61c913911fafb35432eca4bd7cb532087ffa24/build-scripts/generic-packer-build-script.sh

# expects VAGRANT_CLOUD_TOKEN
# env var to be set in calling environmnent.

# requires curl >= 7.76.
# On ubuntu, you might need to run:
#   $ sudo add-apt-repository ppa:savoury1/curl34
#   $ sudo apt-get install curl

if (( $# != 2 )); then
  echo >&2 "expected 2 args: PATH_TO_BOX PATH_TO_MD5"
  exit 1
fi

BOX_PATH="$1"; shift
BOX_MD5="$(cat $1 | awk '{print $1; }')"; shift

setup_colors() {
  if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
    # shellcheck disable=SC2034
    NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m'
    BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m';
  else
    # shellcheck disable=SC2034
    NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
  fi
}

setup_colors

MAKE_ARGS=--no-print-directory

set -e

# if set (e.g. cos running in github CI),
# take box version from ${release_name}
if [ -n "$release_name" ] ; then
  BOX_VERSION="${release_name}";
else
  BOX_VERSION="$(make $MAKE_ARGS print_box_version)";
fi

set -uo pipefail

BOX_NAME="$(make $MAKE_ARGS print_box_name)"
PROVIDER_TYPE="virtualbox"

SHORT_DESC="$(make $MAKE_ARGS print_short_desc)"
VAGRANT_CLOUD_USERNAME="$(make $MAKE_ARGS  print_vagrant_cloud_username)"
GITHUB_REPO="$(make $MAKE_ARGS  print_github_repo)"

printf '\n'"${GREEN}%s${NOFORMAT}"'\n' "ensuring vagrant-cloud box exists named ${VAGRANT_CLOUD_USERNAME}/$BOX_NAME has been created"

cat > .box_metadata <<END
{
  "box": {
    "username": "$VAGRANT_CLOUD_USERNAME",
    "name": "$BOX_NAME",
    "short_description": "$SHORT_DESC",
    "description": "$(make $MAKE_ARGS print_desc)",
    "is_private": false
  }
}
END

res=0
(set -x && curl https://vagrantcloud.com/api/v1/boxes \
        --fail-with-body \
        -X POST \
        --header "Content-Type: application/json" \
        --header "Authorization: Bearer $VAGRANT_CLOUD_TOKEN" \
        --data-binary @.box_metadata \
  | tee .box_result) \
  || res=$?

if [ "$res" -eq 22 ]; then
  if grep 'already been taken' .box_result > /dev/null; then
    printf '\n\n'"${ORANGE}%s${NOFORMAT}"'\n' "box already exists, but continuing"
  else
    printf '\n'"${RED}%s${NOFORMAT}"'\n' "couldn't create box, exiting"
    exit 1;
  fi
fi

printf '\n'"${GREEN}%s${NOFORMAT}"'\n' "ensuring vagrant-cloud box named $VAGRANT_CLOUD_USERNAME/$BOX_NAME has version $BOX_VERSION created"

cat > .version_metadata <<END
{
  "version": {
    "version": "$BOX_VERSION",
    "description": "$(make $MAKE_ARGS print_desc).\n\nSee <${GITHUB_REPO}/releases/tag/v$BOX_VERSION>"
  }
}
END

res=0
(set -x && curl "https://vagrantcloud.com/api/v1/box/$VAGRANT_CLOUD_USERNAME/$BOX_NAME/versions" \
        --fail-with-body \
        -X POST \
        --header "Content-Type: application/json" \
        --header "Authorization: Bearer $VAGRANT_CLOUD_TOKEN" \
        --data-binary @.version_metadata \
        | tee .version_result) \
  || res=$?

if [ "$res" -eq 22 ]; then
  if grep 'already been taken' .version_result > /dev/null; then
    printf '\n\n'"${ORANGE}%s${NOFORMAT}"'\n' "version already exists, but continuing"
  else
    printf '\n'"${RED}%s${NOFORMAT}"'\n' "couldn't create version, exiting"
    exit 1;
  fi
fi

printf '\n'"${GREEN}%s${NOFORMAT}"'\n' "ensuring vagrant-cloud box named $VAGRANT_CLOUD_USERNAME/$BOX_NAME has ${PROVIDER_TYPE} provider created"

# See <https://www.vagrantup.com/vagrant-cloud/api>, "Create a provider":
# can set e.g.
#   "checksum": "a59e7332e8bbe896f11f478fc61fa8a6",
#   "checksum_type": "md5"

cat > .provider_metadata <<END
{
  "provider": {
    "name": "virtualbox",
    "checksum": "${BOX_MD5}",
    "checksum_type": "md5"
  }
}
END

res=0
(set -x && curl "https://vagrantcloud.com/api/v1/box/$VAGRANT_CLOUD_USERNAME/$BOX_NAME/version/$BOX_VERSION/providers" \
        --fail-with-body \
        -X POST \
        --header "Content-Type: application/json" \
        --header "Authorization: Bearer $VAGRANT_CLOUD_TOKEN" \
        --data-binary @.provider_metadata \
        | tee .provider_result) \
  || res=$?

if [ "$res" -eq 22 ]; then
  if grep 'must be unique' .provider_result > /dev/null; then
    printf '\n\n'"${ORANGE}%s${NOFORMAT}"'\n' "provider already exists, but continuing"
  else
    printf '\n'"${RED}%s${NOFORMAT}"'\n' "couldn't create provider, exiting"
    exit 1;
  fi
fi

printf '\n'"${GREEN}%s${NOFORMAT}"'\n' "getting upload URL"

# get upload URL, expires within (some short time)
res=0
(set -x && : "get upload url" \
        && \
        curl -L \
        --fail-with-body \
        --header "Content-Type: application/json" \
        --header "Authorization: Bearer $VAGRANT_CLOUD_TOKEN" \
        "https://vagrantcloud.com/api/v1/box/$VAGRANT_CLOUD_USERNAME/$BOX_NAME/version/$BOX_VERSION/provider/${PROVIDER_TYPE}/upload" \
    | tee .upload_url_result) \
  || res=$?

if [ "$res" -eq 22 ]; then
  printf '\n'"${RED}%s${NOFORMAT}"'\n' "couldn't get upload URL, exiting"
  exit 1;
fi

printf '\n\n'"${GREEN}%s${NOFORMAT}"'\n' "uploading $VAGRANT_CLOUD_USERNAME/$BOX_NAME vmware_desktop packer .box file"

res=0
VAGRANT_UPLOAD_URL="$(jq --exit-status -r .upload_path  .upload_url_result)" \
  || res=$?

if [ "$res" -ne 0 ]; then
  printf '\n'"${RED}%s${NOFORMAT}"'\n' "couldn't extract upload URL, exiting"
  exit 1;
fi

res=0
(set -x && curl \
          --progress-bar \
          --fail-with-body \
          -X PUT --upload-file "$BOX_PATH" "$VAGRANT_UPLOAD_URL" >/dev/null) \
  || res=$?

if [ "$res" -ne 0 ]; then
  printf '\n'"${RED}%s${NOFORMAT}"'\n' "couldn't upload box, exiting"
  exit 1;
fi

printf '\n'"${GREEN}%s${NOFORMAT}"'\n' "releasing version $BOX_VERSION of $VAGRANT_CLOUD_USERNAME/$BOX_NAME $PROVIDER_TYPE"

res=0
(set -x && curl \
          -X PUT \
          --header "Authorization: Bearer $VAGRANT_CLOUD_TOKEN" \
          "https://vagrantcloud.com/api/v1/box/$VAGRANT_CLOUD_USERNAME/$BOX_NAME/version/$BOX_VERSION/release"  > .release_result) \
  || res=$?


jq . .release_result

