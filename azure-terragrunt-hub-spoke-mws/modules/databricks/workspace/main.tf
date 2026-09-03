# Generate a random string for dbfs (workspace root storage) naming
resource "random_string" "this" {
  special = false
  upper   = false
  length  = 8
}
