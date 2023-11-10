variable "version" {
  type    = string
  default = "latest"
}

source "docker" "debian" {
  commit  = true
  image   = "debian:12"
}

build {
  sources = ["source.docker.debian"]

  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive",
      "DEBIAN_PRIORITY=critical"
    ]
    inline           = [
      "set -e",
      "set -x",
      "echo 'Acquire::http::proxy \"http://10.0.10.22:3142\";' | tee /etc/apt/apt.conf.d/01proxy",
      "apt-get update",
      "apt-get -y dist-upgrade",
    ]
    inline_shebang   = "/bin/bash -e"
  }

  provisioner "file" {
    source = "/opt/drone/age-key.txt"
    destination = "/etc/age-key.txt"
  }

  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive",
      "DEBIAN_PRIORITY=critical"
    ]
    inline           = [
      "set -e",
      "set -x",
      "apt-get -y install wget puppet",
      "wget https://github.com/getsops/sops/releases/download/v3.8.1/sops-v3.8.1.linux.amd64 -O /usr/local/bin/sops",
      "chmod +x /usr/local/bin/sops",
      "chmod a+r /etc/age-key.txt",
    ]
    inline_shebang   = "/bin/bash -e"
  }

  post-processor "docker-tag" {
    repository = "kester-cloud/sops"
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
