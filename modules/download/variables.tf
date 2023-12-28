variable "stable" {
  type = string
}

variable "release" {
  type        = string
  description = <<-EOT
    The value of the git tag associated with the release to find.
    Specify "latest" to find the latest release (default).
  EOT
}

variable "path" {
  type        = string
  description = <<-EOT
    The path to download the files to.
    If not specified, the files will be downloaded to a directory named "rke2" in the root module.
  EOT
}

variable "system" {
  type        = string
  description = <<-EOT
    The kernel of the system to download for.
    Valid values are currently just linux (the default).
  EOT
}
variable "arch" {
  type        = string
  description = <<-EOT
    The architecture of the system to download for.
    Valid values are amd64 (for any x86_64), arm64, or s390x.
  EOT
}

variable "install_url" {
  type = string
}

variable "ssh_ip" {
  type        = list
  description = <<-EOT
    The IP address of the server to install RKE2 on.
    We will attempt to open an ssh connection on this IP address.
    Ssh port must be open and listening, and the user must have sudo/admin privileges.
    This script will only run the install script, please ensure that the server is ready.
  EOT
}
variable "ssh_ip_workers" {
   type        = list
  description = <<-EOT
    The IP address of the server to install RKE2 on.
    We will attempt to open an ssh connection on this IP address.
    Ssh port must be open and listening, and the user must have sudo/admin privileges.
    This script will only run the install script, please ensure that the server is ready.
  EOT
}
variable "ssh_user" {
  type        = string
  description = <<-EOT
    The user to log into the server to install RKE2 on.
    We will attempt to open an ssh connection with this user.
    The user must have sudo/admin privileges.
    This script will only run the install script, please ensure that the server is ready.
  EOT
}
variable "ssh_key" {
  type = string
}

variable "remote_workspace" {
  type        = string
  description = <<-EOT
    The path to a directory where the module can store temporary files and execute scripts. eg. "/var/tmp"
    The user specified in the ssh_user variable must have read, write, and execute permissions to this directory.
    If left blank "/home/<ssh_user>" will be used.
  EOT
}

variable "remote_path" {
  type = string
}

variable "all_hosts" {
  type = list
}