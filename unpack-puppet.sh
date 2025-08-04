#!/bin/bash

set -e
set -x

VERSION="${BOLT_VERSION:-4.0.0-1}"

mkdir -p build/pkg

wget -O build/puppet.deb https://apt.puppet.com/pool/bookworm/puppet/p/puppet-bolt/puppet-bolt_"$VERSION"bookworm_amd64.deb
dpkg-deb -R build/puppet.deb build/pkg
