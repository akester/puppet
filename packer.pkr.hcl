variable "sops_version" {
  type    = string
  default = "3.10.2"
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

  # Install some helper software we'll use to install other things
  provisioner "shell" {
    inline = [
      "apk add --no-cache wget",
      "apk add --no-cache coreutils", # For install
      "apk add --no-cache rsync",
    ]
  }

  # Install sops
  provisioner "shell" {
    inline = [
      "wget -nv -O /tmp/sops https://github.com/getsops/sops/releases/download/v${var.sops_version}/sops-v${var.sops_version}.linux.amd64",
      "install -m 0755 /tmp/sops /usr/bin/"
    ]
  }

  # Install puppet
  provisioner "file" {
    source = "./build/pkg/"
    destination = "/tmp/pkg/"
  }
  provisioner "shell" {
    inline = [
      "set -x",
      "rsync -ra /tmp/pkg/usr/ /usr/",
      "rsync -ra /tmp/pkg/opt/ /opt/",
      "chmod 0755 /opt/puppetlabs/bin/bolt",
      "chmod 0755 /usr/local/bin/bolt",
    ]
  }

  # Remove APK cache for space
  provisioner "shell" {
    inline = [
      "rm -rf /var/cache/apk/*",
      "rm -rf /tmp/*",
    ]
  }

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
      "alpine"
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
