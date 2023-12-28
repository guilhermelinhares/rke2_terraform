output "files" {
  value       = local.files
  description = <<-EOT
    A list of the files downloaded and their URLs.
  EOT
}
output "tag" {
  value       = var.stable
  description = <<-EOT
    The tag of the release that was found.
  EOT
}
output "path" {
  value       = var.path
  description = <<-EOT
    The path where the files were downloaded to.
  EOT
}
