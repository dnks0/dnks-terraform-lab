locals {
  deployer_ip = jsondecode(data.http.deployer_ip.response_body).ip
}
