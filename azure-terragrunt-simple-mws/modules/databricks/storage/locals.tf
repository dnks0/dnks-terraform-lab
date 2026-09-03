locals {
  deployer_ip = jsondecode(data.http.deployer_ip.response_body).ip

  # Azure storage account names must be lowercase alphanumeric, 3-24 chars. This stack's
  # prefix-derived name currently lands at exactly 24, so truncate defensively to stay valid
  # if the prefix/env/bu grows (substr is a no-op at <=24). The leading stack/env/bu segments
  # — the distinguishing parts — are preserved.
  storage_account_name = substr(replace(var.prefix, "-", ""), 0, 24)
}
