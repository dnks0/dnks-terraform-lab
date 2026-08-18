# Deployer public IP, used to allow the deploying host through the storage firewall.
data "http" "deployer_ip" {
  url = "https://ifconfig.co/json"
  request_headers = {
    Accept = "application/json"
  }
}
