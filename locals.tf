locals {
  system              = var.system
  arch                = var.arch
  release             = var.release
  stable              = (var.release == "stable" ? true : false)
  install_url         = "https://raw.githubusercontent.com/rancher/rke2/master/install.sh"
  path                = abspath(var.path)
  ssh_ip              = var.ssh_ip
  ssh_ip_workers      = var.ssh_ip_workers
  ssh_user            = var.ssh_user
  remote_workspace   = ((var.remote_workspace == "~" || var.remote_workspace == "") ? "/home/${local.ssh_user}" : var.remote_workspace) # https://github.com/hashicorp/terraform/issues/30243
  remote_path         = (var.remote_file_path == "" ? "${local.remote_workspace}/rke2_artifacts" : var.remote_file_path)
  all_hosts           = concat(var.ssh_ip, var.ssh_ip_workers)
}