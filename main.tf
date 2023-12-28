module "rke2_download" {
  source      = "./modules/download"

  stable              = local.stable
  release             = local.release
  path                = local.path
  system              = local.system
  arch                = local.arch
  install_url         = local.install_url
  ssh_ip              = local.ssh_ip
  ssh_ip_workers      = local.ssh_ip_workers
  ssh_user            = local.ssh_user
  ssh_key             = var.ssh_key
  remote_workspace    = local.remote_workspace
  remote_path         = local.remote_path
  all_hosts           = local.all_hosts
}

module "rke2_install" {
  depends_on = [ module.rke2_download ]
  source = "./modules/install"

  release             = local.release
  role                = var.role
  role_worker         = var.role_worker
  ssh_ip              = local.ssh_ip
  ssh_ip_workers      = local.ssh_ip_workers
  ssh_user            = local.ssh_user
  ssh_key             = var.ssh_key
  identifier          = var.identifier
  local_file_path     = var.local_file_path
  remote_workspace    = local.remote_workspace
  remote_path         = local.remote_path
  retrieve_kubeconfig = var.retrieve_kubeconfig
  install_method      = var.install_method
  start               = var.start
  start_timeout       = var.start_timeout
  remote_file_path    = var.remote_file_path
  all_hosts           = local.all_hosts
}
