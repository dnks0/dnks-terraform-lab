locals {
  ifconfig_co_json = jsondecode(data.http.this.response_body)
  storage_name = join("", ["${var.environment}${var.business_unit}", random_string.this.result])
}
