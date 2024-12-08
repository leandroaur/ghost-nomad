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
  userKey = "AQDSXGlkc/kiHxAAu0CX8Q/3SveVD0S47a88IA=="
}

parameters {
  clusterID = "0f435b30-f745-11ed-a325-c62fc3e066af" #"<insert_the_id>"
  pool = "nomad"
  imageFeatures = "layering"
}

