variable "version" {
  type    = string
}

source "docker" "debian-amd64" {
  commit = true
  image  = "debian:13"
  platform = "linux/amd64"
}

build {
  sources = [
    "source.docker.debian-amd64",
  ]

  # Use the local apt cache (amd64 only), removed at the end of the build
  provisioner "shell" {
    only = ["docker.debian-amd64"]
    inline = [
      "set -e",
      "set -x",
      "cp /etc/apt/sources.list.d/debian.sources /root/debian.sources.orig",
      "sed -i 's#http://deb.debian.org/#http://apt.kester.cloud/#' /etc/apt/sources.list.d/debian.sources",
    ]
    inline_shebang = "/bin/bash -e"
  }

  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive",
      "DEBIAN_PRIORITY=critical"
    ]
    inline           = [
      "set -e",
      "set -x",
      "apt-get update",
      "apt-get -y dist-upgrade",
    ]
    inline_shebang   = "/bin/bash -e"
  }

  # Install Sops
  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive",
      "DEBIAN_PRIORITY=critical"
    ]
    inline           = [
      "set -e",
      "set -x",
      "apt-get -y install wget",
      "wget -nv https://github.com/getsops/sops/releases/download/v3.8.1/sops-v3.8.1.linux.amd64 -O /usr/local/bin/sops",
      "chmod +x /usr/local/bin/sops",
    ]
    inline_shebang   = "/bin/bash -e"
  }

  # Install puppet / other apt packages
  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive",
      "DEBIAN_PRIORITY=critical"
    ]
    inline           = [
      "set -e",
      "set -x",
      "apt-get -y install puppet git build-essential jq",
    ]
    inline_shebang   = "/bin/bash -e"
  }

  # Install Puppet repos / Bolt
  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive",
      "DEBIAN_PRIORITY=critical"
    ]
    inline           = [
      "set -e",
      "set -x",
      "wget -nv -O /tmp/openvox-release.deb https://apt.voxpupuli.org/openvox8-release-debian13.deb",
      "dpkg -i /tmp/openvox-release.deb",
      "apt-get update",
      "apt-get install -y openbolt",
    ]
    inline_shebang   = "/bin/bash -e"
  }

  # Install hashicorp rerpos / terraform
  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive",
      "DEBIAN_PRIORITY=critical"
    ]
    inline           = [
      "set -e",
      "set -x",
      "apt-get install -y gnupg",
      "wget -nv -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null",
      "echo \"deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main\" | tee /etc/apt/sources.list.d/hashicorp.list",
      "apt-get update",
      "apt-get install terraform",
    ]
    inline_shebang   = "/bin/bash -e"
  }

  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive",
      "DEBIAN_PRIORITY=critical"
    ]
    inline           = [
      "set -e",
      "set -x",
      "rm -f /etc/apt/apt.conf.d/01proxy",
      "apt update",
      "apt autoremove",
      "apt clean",
    ]
    inline_shebang   = "/bin/bash -e"
  }

  # Remove the local apt cache
  provisioner "shell" {
    only = ["docker.debian-amd64"]
    inline = [
      "set -e",
      "set -x",
      "mv /root/debian.sources.orig /etc/apt/sources.list.d/debian.sources",
      "rm -rf /var/lib/apt/lists/*",
    ]
    inline_shebang = "/bin/bash -e"
  }

  post-processor "docker-tag" {
    repository = "akester/puppet"
    tags = [
      "${source.name}-${var.version}",
    ]
  }
}

packer {
  required_plugins {
    docker = {
      version = ">= 0.0.7"
      source = "github.com/hashicorp/docker"
    }
  }
}
