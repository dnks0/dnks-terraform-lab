locals {
  title_cased_region = title(var.region)

  service_tags = {
    "sql" : "Sql.${local.title_cased_region}",
    "storage" : "Storage.${local.title_cased_region}",
    "eventhub" : "EventHub.${local.title_cased_region}"
  }
}
