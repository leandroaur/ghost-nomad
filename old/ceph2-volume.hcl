id = "ceph-mysql"
name = "ceph-mysql"
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
  userKey = "AQDCIGlkgSy/GRAACQGLPesLLnkNUi1GYqnjVg=="
}

parameters {
  clusterID = "0f435b30-f745-11ed-a325-c62fc3e066af"
  pool = "nomad"
  imageFeatures = "layering"
}
