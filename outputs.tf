#region - Output Module Download

    output "files" {
    value       = module.rke2_download.files
    description = <<-EOT
        A list of the files downloaded and their URLs.
    EOT
    }
    output "tag" {
    value       = module.rke2_download.tag
    description = <<-EOT
        The tag of the release that was found.
    EOT
    }
    output "path" {
    value       = module.rke2_download.path
    description = <<-EOT
        The path where the files were downloaded to.
    EOT
    }

#endregion

# region - Output Module Install

    output "kubeconfig" {
    value       = module.rke2_install.kubeconfig
    description = <<-EOT
        The contents of the kubeconfig file.
    EOT
    sensitive   = true
    }

#endregion