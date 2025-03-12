#!/usr/bin/env bash

# Test whether our `provision-mac.sh` script works.
# Should work regardless of whether we're (a) root, but don't have sudo installed
# (e.g. in a docker container), or (b) non-root, but have sudo access (e.g. in a
# vagrant box).

maybesudo () {
  if [[ $UID -eq 0 ]]; then
    "$@"
  else
    sudo "$@"
  fi
}

set -euo pipefail
set -x

maybesudo apt-get update
maybesudo env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends curl ca-certificates sudo

cat provision-mac.sh | sudo bash
