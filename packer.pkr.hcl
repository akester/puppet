variable "version" {
  type    = string
  default = "latest"
}

source "docker" "alpine" {
  commit  = true
  image   = "alpine:latest"
}

build {
  sources = ["source.docker.alpine"]

  # Upgrade the software
  provisioner "shell" {
    inline = [
      "apk update",
      "apk upgrade",
    ]
  }

  # Remove APK cache for space
  provisioner "shell" {
    inline = [
      "rm -rf /var/cache/apk/*",
    ]
  }

  # provisioner "shell" {
  #   environment_vars = [
  #     "alpine_FRONTEND=noninteractive",
  #     "alpine_PRIORITY=critical"
  #   ]
  #   inline           = [
  #     "set -e",
  #     "set -x",
  #     "apt-get update",
  #     "apt-get -y dist-upgrade",
  #   ]
  #   inline_shebang   = "/bin/bash -e"
  # }

  # # Install Sops
  # provisioner "shell" {
  #   environment_vars = [
  #     "alpine_FRONTEND=noninteractive",
  #     "alpine_PRIORITY=critical"
  #   ]
  #   inline           = [
  #     "set -e",
  #     "set -x",
  #     "apt-get -y install wget",
  #     "wget https://github.com/getsops/sops/releases/download/v3.8.1/sops-v3.8.1.linux.amd64 -O /usr/local/bin/sops",
  #     "chmod +x /usr/local/bin/sops",
  #   ]
  #   inline_shebang   = "/bin/bash -e"
  # }

  # # Install puppet / other apt packages
  # provisioner "shell" {
  #   environment_vars = [
  #     "alpine_FRONTEND=noninteractive",
  #     "alpine_PRIORITY=critical"
  #   ]
  #   inline           = [
  #     "set -e",
  #     "set -x",
  #     "apt-get -y install puppet git build-essential",
  #   ]
  #   inline_shebang   = "/bin/bash -e"
  # }

  # # Install Puppet repos / Bolt
  # provisioner "shell" {
  #   environment_vars = [
  #     "alpine_FRONTEND=noninteractive",
  #     "alpine_PRIORITY=critical"
  #   ]
  #   inline           = [
  #     "set -e",
  #     "set -x",
  #     "wget -O /tmp/puppet-release.deb https://apt.puppet.com/puppet-tools-release-bullseye.deb",
  #     "dpkg -i /tmp/puppet-release.deb",
  #     "apt-get update",
  #     "apt-get install puppet-bolt pdk",
  #   ]
  #   inline_shebang   = "/bin/bash -e"
  # }

  # # Install hashicorp rerpos / terraform
  # provisioner "shell" {
  #   environment_vars = [
  #     "alpine_FRONTEND=noninteractive",
  #     "alpine_PRIORITY=critical"
  #   ]
  #   inline           = [
  #     "set -e",
  #     "set -x",
  #     "apt-get install -y gnupg software-properties-common",
  #     "wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null",
  #     "echo \"deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main\" | tee /etc/apt/sources.list.d/hashicorp.list",
  #     "apt-get update",
  #     "apt-get install terraform",
  #   ]
  #   inline_shebang   = "/bin/bash -e"
  # }

  # provisioner "shell" {
  #   environment_vars = [
  #     "alpine_FRONTEND=noninteractive",
  #     "alpine_PRIORITY=critical"
  #   ]
  #   inline           = [
  #     "set -e",
  #     "set -x",
  #     "rm -f /etc/apt/apt.conf.d/01proxy",
  #     "apt update",
  #     "apt autoremove",
  #     "apt clean",
  #   ]
  #   inline_shebang   = "/bin/bash -e"
  # }

  post-processor "docker-tag" {
    repository = "akester/puppet"
    tags       = [
      "${var.version}"
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
