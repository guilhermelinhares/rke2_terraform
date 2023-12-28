# create a directory to download the files to if path does not exist
resource "local_file" "download_dir" {
  filename             = "${var.path}/README.md"
  content              = <<-EOT
    # RKE2 Downloads
    This directory is used to download the RKE2 installer and images.
  EOT
  directory_permission = "0755"
  file_permission      = "0644"
}

# requires curl to be installed in the environment running terraform
resource "null_resource" "download" {
  depends_on = [
    local_file.download_dir,
  ]
  for_each = local.files
  provisioner "local-exec" {
    command = <<-EOT
      curl -L -s -o ${abspath("${var.path}/${each.key}")} ${each.value}
    EOT
  }
}

# if local path specified copy all files and folders to the remote_path directory
resource "null_resource" "copy_files" {
  depends_on = [ null_resource.download ]
  count = length(var.all_hosts)
  connection {
    type        = "ssh"
    user        = var.ssh_user
    script_path = "${var.remote_workspace}/rke2_copy_terraform_files"
    agent       = true
    host        = var.all_hosts[count.index]
    private_key = file(var.ssh_key)
  }  

  provisioner "file" {
    source      = "${abspath("${var.path}/rke2-images.${var.system}-${var.arch}.tar.gz")}"
    destination = "${var.remote_path}/rke2-images.${var.system}-${var.arch}.tar.gz"
  }
  provisioner "file" {
    source      = "${abspath("${var.path}/rke2.${var.system}-${var.arch}.tar.gz")}"
    destination = "${var.remote_path}/rke2.${var.system}-${var.arch}.tar.gz"
  }
  provisioner "file" {
    source      = "${abspath("${var.path}/sha256sum-${var.arch}.txt")}"
    destination = "${var.remote_path}/sha256sum-${var.arch}.txt"
  }
  provisioner "file" {
    source      = "${abspath("${var.path}/install.sh")}"
    destination = "${var.remote_path}/install.sh"
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