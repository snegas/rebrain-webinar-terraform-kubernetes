locals {
  files_list = tolist(fileset("${path.module}/configs", "**"))
  keys = tolist([for i in local.files_list : basename(i)])
  files_map = zipmap(local.keys, local.files_list)
}

resource "kubernetes_config_map" "nginx" {
  for_each = local.files_map

  metadata {
    name = each.key
  }

  data = {
    (each.key) = file("${path.module}/configs/${each.value}")
  }
}