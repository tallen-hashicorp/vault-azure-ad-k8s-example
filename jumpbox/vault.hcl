storage "raft" {
  path    = "./vault/data"
  node_id = "node1"
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_cert_file = "/etc/letsencrypt/live/vault.the-tech-tutorial.com/fullchain.pem"
  tls_key_file  = "/etc/letsencrypt/live/vault.the-tech-tutorial.com/privkey.pem"
}

api_addr = "https://vault.the-tech-tutorial.com:8200"
cluster_addr = "http://vault.the-tech-tutorial.com:8201"
ui = true

license_path = "/tmp/vault.hclic"
log_level = "trace"

telemetry {
  prometheus_retention_time = "30s"
  disable_hostname = true
}

disable_mlock = true