locals {
    # selected_assets = (can(data.github_release.selected[0].assets) ? { for a in data.github_release.selected[0].assets : a.name => a.browser_download_url } : {})
    # latest_assets   = (can(data.github_release.latest.assets) ? { for a in data.github_release.latest.assets : a.name => a.browser_download_url } : {})
    # assets          = (var.stable ? local.latest_assets : local.selected_assets)
    github_url                                              = "https://github.com/rancher/rke2/releases/download/v1.26.11+rke2r1"
    files = {
        "rke2-images.${var.system}-${var.arch}.tar.gz"      = "${local.github_url}/rke2-images.${var.system}-${var.arch}.tar.gz",
        "rke2.${var.system}-${var.arch}.tar.gz"             = "${local.github_url}/rke2.${var.system}-${var.arch}.tar.gz",
        "sha256sum-${var.arch}.txt"                         = "${local.github_url}/sha256sum-${var.arch}.txt",
        "install.sh"                                        = var.install_url,
    }
}