locals {
  deployer_ip = jsondecode(data.http.deployer_ip.response_body).ip

  # Azure storage account names must be lowercase alphanumeric, 3-24 chars. The prefix-derived
  # name overflows 24 for longer stack prefixes (this stack's prefix is longer than the simple
  # stack's, which sits exactly at 24), so truncate. The leading stack/env/bu segments — the
  # distinguishing parts — are preserved.
  storage_account_name = substr(replace(var.prefix, "-", ""), 0, 24)
}
