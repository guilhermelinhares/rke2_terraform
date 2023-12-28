resource "random_string" "random" {
  length           = 16
  special          = true
  override_special = "/@£$"
}

# if local path specified copy all files and folders to the remote_path directory
resource "null_resource" "copy_to_remote" {
  triggers = {
    id = local.identifier,
  }
  count = length(var.all_hosts)
  connection {
    type        = "ssh"
    user        = var.ssh_user
    script_path = "${var.remote_workspace}/rke2_copy_terraform"
    agent       = true
    host        = var.all_hosts[count.index]
    private_key = file(var.ssh_key)
  }
  provisioner "file" {
    source      = local.local_path
    destination = var.remote_path
  }
  provisioner "remote-exec" {
    inline = [<<-EOT
      set -x
      set -e
      ls -lah "${var.remote_path}"
    EOT
    ]
  }
}
resource "null_resource" "configure" {
  depends_on = [
    null_resource.copy_to_remote,
  ]
  triggers = {
    id = local.identifier,
  }
  count = length(var.all_hosts)
  connection {
    type        = "ssh"
    user        = var.ssh_user
    script_path = "${var.remote_workspace}/rke2_config_terraform"
    agent       = true
    host        = var.all_hosts[count.index]
    private_key = file(var.ssh_key)
  }
  provisioner "file" {
    source      = "${abspath(path.module)}/files/configure.sh"
    destination = "${var.remote_workspace}/configure.sh"
  }
  provisioner "remote-exec" {
    inline = [<<-EOT
      set -x
      set -e
      sudo chmod +x ${var.remote_workspace}/configure.sh
      sudo ${var.remote_workspace}/configure.sh "${var.remote_path}"
    EOT
    ]
  }
}
# run the install script, which may upgrade rke2 if it is already installed
resource "null_resource" "install_control_plane" {
  depends_on = [
    null_resource.copy_to_remote,
    null_resource.configure,
  ]
  triggers = {
    id = local.identifier,
  }
  count = length(var.ssh_ip)
  connection {
    type        = "ssh"
    user        = var.ssh_user
    script_path = "${var.remote_workspace}/rke2_install_terraform"
    agent       = true
    host        = var.ssh_ip[count.index]
    private_key = file(var.ssh_key)
  }
  provisioner "file" {
    source      = "${abspath(path.module)}/files/install.sh"
    destination = "${var.remote_workspace}/install.sh"
  }
  provisioner "remote-exec" {
    inline = [<<-EOT
      set -x
      set -e
      sudo chmod +x "${var.remote_workspace}/install.sh"
      sudo ${var.remote_workspace}/install.sh "${local.role}" "${var.remote_path}" "${var.release}" "${local.install_method}"
    EOT
    ]
  }
}

resource "null_resource" "install_workers" {
  depends_on = [
    null_resource.copy_to_remote,
    null_resource.configure,
  ]
  triggers = {
    id = local.identifier,
  }
  count = length(var.ssh_ip_workers)
  connection {
    type        = "ssh"
    user        = var.ssh_user
    script_path = "${var.remote_workspace}/rke2_install_terraform"
    agent       = true
    host        = var.ssh_ip_workers[count.index]
    private_key = file(var.ssh_key)
  }
  provisioner "file" {
    source      = "${abspath(path.module)}/files/install.sh"
    destination = "${var.remote_workspace}/install.sh"
  }
  provisioner "remote-exec" {
    inline = [<<-EOT
      set -x
      set -e
      sudo chmod +x "${var.remote_workspace}/install.sh"
      sudo ${var.remote_workspace}/install.sh "${local.role_worker}" "${var.remote_path}" "${var.release}" "${local.install_method}"
    EOT
    ]
  }
}
# start or restart rke2 service
resource "null_resource" "start_control_plane" {
  count = length(var.ssh_ip)
  depends_on = [
    null_resource.copy_to_remote,
    null_resource.configure,
    null_resource.install_control_plane,
    null_resource.install_workers,
  ]
  triggers = {
    id = local.identifier,
  }
  connection {
    type        = "ssh"
    user        = var.ssh_user
    script_path = "${var.remote_workspace}/rke2_start_terraform"
    agent       = true
    host        = var.ssh_ip[count.index]
    private_key = file(var.ssh_key)
  }
  provisioner "file" {
    source      = "${abspath(path.module)}/files/start.sh"
    destination = "${var.remote_workspace}/start.sh"
  }
  provisioner "remote-exec" {
    inline = [<<-EOT
        set -x
        set -e
        sudo chmod +x ${var.remote_workspace}/start.sh
        sudo ${var.remote_workspace}/start.sh "${local.role}" "${local.start_timeout}"
    EOT
    ]
  }
}

resource "null_resource" "get_kubeconfig" {
  count = length(var.ssh_ip)
  depends_on = [
    null_resource.copy_to_remote,
    null_resource.configure,
    null_resource.install_control_plane,
    null_resource.install_workers,
    null_resource.start_control_plane,
  ]
  triggers = {
    id = local.identifier,
  }
  connection {
    type        = "ssh"
    user        = var.ssh_user
    script_path = "${var.remote_workspace}/get_kubeconfig_terraform"
    agent       = true
    host        = var.ssh_ip[count.index]
    private_key = file(var.ssh_key)
  }
  provisioner "remote-exec" {
    inline = [<<-EOT
      set -x
      set -e
      sudo cp /etc/rancher/rke2/rke2.yaml "${var.remote_workspace}/kubeconfig.yaml"
      sudo chown ${var.ssh_user} "${var.remote_workspace}/kubeconfig.yaml"
    EOT
    ]
  }
  provisioner "local-exec" {
    command = <<-EOT
      set -x
      set -e
      FILE="${abspath(path.root)}/rke2/kubeconfig-${local.identifier}.yaml"
      REMOTE_PATH="${var.remote_workspace}/kubeconfig.yaml"
      IP="${var.ssh_ip[count.index]}"
      SSH_USER="${var.ssh_user}"

      chmod +x "${abspath(path.module)}/files/get_kubeconfig.sh"
      "${abspath(path.module)}/files/get_kubeconfig.sh" "$FILE" "$REMOTE_PATH" "$IP" "$SSH_USER"
    EOT
  }
  
}

resource "null_resource" "get_tokenconfig" {
  count = length(var.ssh_ip)
  depends_on = [
    null_resource.copy_to_remote,
    null_resource.configure,
    null_resource.install_control_plane,
    null_resource.install_workers,
    null_resource.start_control_plane,
  ]
  triggers = {
    id = local.identifier,
  }
  connection {
    type        = "ssh"
    user        = var.ssh_user
    script_path = "${var.remote_workspace}/get_tokenconfig_terraform"
    agent       = true
    host        = var.ssh_ip[count.index]
    private_key = file(var.ssh_key)
  }
  provisioner "remote-exec" {
    inline = [<<-EOT
      set -x
      set -e
      TOKEN=$(sudo cat /var/lib/rancher/rke2/server/node-token)
      cat >${var.remote_workspace}/config.yaml <<'NEW_FILE_CONFIG_WORKERS'
      server: https://${var.ssh_ip[count.index]}:9345
      token: TOKEN
      NEW_FILE_CONFIG_WORKERS
      sed -i -e "s/TOKEN/$TOKEN/g" ${var.remote_workspace}/config.yaml
    EOT
    ]
  }
   provisioner "local-exec" {
    command = <<-EOT
      set -x
      set -e
      FILE="${abspath(path.root)}/rke2/config.yaml"
      REMOTE_PATH="${var.remote_workspace}/config.yaml"
      IP="${var.ssh_ip[count.index]}"
      SSH_USER="${var.ssh_user}"

      chmod +x "${abspath(path.module)}/files/get_tokenconfig.sh"
      "${abspath(path.module)}/files/get_tokenconfig.sh" "$FILE" "$REMOTE_PATH" "$IP" "$SSH_USER"
    EOT
  }
  
}

# start or restart rke2 service
resource "null_resource" "start_workers" {
    count = length(var.ssh_ip_workers)
    depends_on = [
        null_resource.copy_to_remote,
        null_resource.configure,
        null_resource.install_control_plane,
        null_resource.install_workers,
        null_resource.start_control_plane,
        null_resource.get_kubeconfig,
        null_resource.get_tokenconfig
    ]
    triggers = {
        id = local.identifier,
    }
    connection {
        type        = "ssh"
        user        = var.ssh_user
        script_path = "${var.remote_workspace}/rke2_start_terraform"
        agent       = true
        host        = var.ssh_ip_workers[count.index]
        private_key = file(var.ssh_key)
    }
    provisioner "file" {
        source      = "${abspath(path.root)}/rke2/config.yaml"
        destination = "${var.remote_workspace}/config.yaml"
    }
    provisioner "file" {
        source      = "${abspath(path.module)}/files/start.sh"
        destination = "${var.remote_workspace}/start.sh"
    }
    provisioner "remote-exec" {
        inline = [<<-EOT
            set -x
            set -e
            sudo cp ${var.remote_workspace}/config.yaml "/etc/rancher/rke2/config.yaml"
            EOT
        ]
    }
    provisioner "remote-exec" {
        inline = [<<-EOT
        set -x
        set -e
        sudo chmod +x ${var.remote_workspace}/start.sh
        sudo ${var.remote_workspace}/start.sh "${local.role_worker}" "${local.start_timeout}"
        EOT
        ]
    }
}