# Puppet

This is a container with a few build tools used to build my internal Puppet code
and set it up for deployments.  It's based on Debian 11 (because reasons), and
includes these tools:

* puppet
* puppet bolt
* sops
* terraform

It also has the upstream Hashicorp and Puppet upstream repos installed, so you
can install other packages you need.

## Building

This container is based on Debian 11 due to compatibility with Puppet's release
code.  At some point, I may port the whole thing to Debian 12 or Alpine.

The container is built using Packer and has a Makefile, just run `make` to start
a build.


## Mirror

If you're looking at this repo at https://github.com/akester/puppet/, know
that it's a mirror of my local code repository.  This repo is monitored though,
so any pull requests or issues will be seen.
