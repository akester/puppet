# Puppet

This is a container with a few build tools used to build my internal Puppet code
and set it up for deployments.  It includes these tools:

* puppet bolt
* sops
* terraform

## Usage

I use this in Drone pipelines to automatically build and deploy puppet code.  You can include it in the pipeline like this:

```
---
kind: pipeline
name: deploy
type: docker

concurrency:
  limit: 1

steps:
- name: submodules
  image: alpine/git
  commands:
  - git submodule init
  - git submodule update --recursive

- name: sops
  image: akester/puppet
  environment:
    SOPS_AGE_KEY_FILE: /tmp/age-key.txt
    SOPS_AGE_KEY:
      from_secret: AGE_KEY
  commands:
    - echo "$AGE_KEY" > /tmp/age-key.txt
    - bash dec.sh

- name: bolt
  image: akester/puppet
  commands:
  - bolt module install

...
```

## Building

This container is built on Alpine, but we use the Debian 12 puppet-bolt debian
package.  We unpack that on our debian host system using `dpkg-deb`, so you'll
need that to run the `unpack-puppet.sh` helper.

The container is built using Packer and has a Makefile, but there's a number of
variables set by the CI config to centralize versions of libraries.   Build locally via:

```
packer init .
packer build .
```

And update `.drone.yml` and use `make` if you're in CI.


## Mirror

If you're looking at this repo at https://github.com/akester/puppet/, know
that it's a mirror of my local code repository.  This repo is monitored though,
so any pull requests or issues will be seen.
