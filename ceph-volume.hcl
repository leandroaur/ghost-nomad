#Use this volume model if you have a ceph volume as csi
id = "ghost-csi"
name = "ghost-csi"
type = "csi"
plugin_id = "ceph-csi"
capacity_max = "20G"
capacity_min = "10G"

capability {
  access_mode     = "single-node-writer"
  attachment_mode = "file-system"
}

secrets {
  userID  = "admin"
  userKey = "<insert_key>"
}

parameters {
  clusterID = "<insert_the_id>"
  pool = "nomad"
  imageFeatures = "layering"
}

