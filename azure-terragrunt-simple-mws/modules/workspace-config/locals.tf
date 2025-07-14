locals {
  ifconfig_co_json = jsondecode(data.http.this.response_body)
}
