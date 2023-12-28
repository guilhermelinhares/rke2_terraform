terraform {
  required_version = "~> 1.6"
  required_providers {
    remote = {
      source = "tenstad/remote"
      version = "0.1.2"
    }
  }
  # backend "pg" {
  #  conn_str = "postgres://TJBDH18:5434/devops?sslmode=disable"
  #  schema_name = "rancher"
  # }
}

provider "remote" {
  alias = "control_plane_1"

  max_sessions = 2

  conn {
    host     = var.ssh_ip
    user      = var.ssh_user
    private_key = var.ssh_key
    sudo     = true
  }
}
