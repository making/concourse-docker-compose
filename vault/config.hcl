ui = true

listener "tcp" {
  address = "0.0.0.0:8200"
  tls_cert_file = "/vault/certs/cert.pem"
  tls_key_file = "/vault/certs/key.pem"
}

storage "file" {
  path = "/vault/file"
}
