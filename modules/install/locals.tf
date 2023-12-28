locals { 
  role                = var.role
  role_worker         = var.role_worker
  identifier          = var.identifier == "~"  ? md5(join("-", [var.release])) : md5(join("-", [var.release]))
  local_file_path     = var.local_file_path
  local_path          = (local.local_file_path == "" ? "${abspath(path.root)}/rke2" : local.local_file_path)
  retrieve_kubeconfig = var.retrieve_kubeconfig
  install_method      = var.install_method
  start               = var.start
  start_timeout       = var.start_timeout
}