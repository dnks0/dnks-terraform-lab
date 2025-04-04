variable "prefix" {
  type        = string
  description = "Prefix to use for any resources"
}

variable "region" {
  type        = string
  description = "The AWS region to deploy to"
}

variable "tags" {
  type        = map(string)
  description = "Optional tags to add to created resources"
}

variable "databricks_account_id" {
  type        = string
  description = "Databricks Account ID"
}

variable "databricks_metastore_ids" {
  type        = list(string)
  description = "Databricks Metastore IDs"
}

variable "databricks_metastore_bucket_arn" {
  type        = string
  description = "Databricks Metastore Bucket ARN"
}

variable "databricks_account_admin_group_id" {
  type        = string
  description = "Databricks Account Admin group ID"
}

variable "vpc_cidr" {
  type        = string
  description = "(Required) The CIDR block for the Virtual Network"

  # Add validation for the CIDR block
  validation {
    condition     = tonumber(split("/", var.vpc_cidr)[1]) < 24
    error_message = "CIDR block must be at least as large as /23"
  }
}

variable "private_subnets_cidr" {
  type        = list(string)
  description = "(Required) The CIDR block for private subnet"
}

variable "public_subnets_cidr" {
  type        = list(string)
  description = "(Required) The CIDR block for public subnets"
}

variable "privatelink_subnets_cidr" {
  type        = list(string)
  description = "(Required) The CIDR block for privatelink subnets"
}

variable "sg_egress_ports" {
  type        = list(string)
  description = "List of egress ports for security groups"
}

variable "backend_rest_vpc_endpoint_service_names" {
  type = map(string)
  description = "Map of all relevant VPC endpoint service names"
  default = {
    "ap-northeast-1" = "com.amazonaws.vpce.ap-northeast-1.vpce-svc-02691fd610d24fd64"
    "ap-northeast-2" = "com.amazonaws.vpce.ap-northeast-2.vpce-svc-0babb9bde64f34d7e"
    "ap-south-1"     = "com.amazonaws.vpce.ap-south-1.vpce-svc-0dbfe5d9ee18d6411"
    "ap-southeast-1" = "com.amazonaws.vpce.ap-southeast-1.vpce-svc-02535b257fc253ff4"
    "ap-southeast-2" = "com.amazonaws.vpce.ap-southeast-2.vpce-svc-0b87155ddd6954974"
    "ca-central-1"   = "com.amazonaws.vpce.ca-central-1.vpce-svc-0205f197ec0e28d65"
    "eu-central-1"   = "com.amazonaws.vpce.eu-central-1.vpce-svc-081f78503812597f7"
    "eu-west-1"      = "com.amazonaws.vpce.eu-west-1.vpce-svc-0da6ebf1461278016"
    "eu-west-2"      = "com.amazonaws.vpce.eu-west-2.vpce-svc-01148c7cdc1d1326c"
    "eu-west-3"      = "com.amazonaws.vpce.eu-west-3.vpce-svc-008b9368d1d011f37"
    "sa-east-1"      = "com.amazonaws.vpce.sa-east-1.vpce-svc-0bafcea8cdfe11b66"
    "us-east-1"      = "com.amazonaws.vpce.us-east-1.vpce-svc-09143d1e626de2f04"
    "us-east-2"      = "com.amazonaws.vpce.us-east-2.vpce-svc-041dc2b4d7796b8d3"
    "us-west-2"      = "com.amazonaws.vpce.us-west-2.vpce-svc-0129f463fcfbc46c5"
    #"us-west-1" = ""
  }
}

variable "backend_relay_vpc_endpoint_service_names" {
  type = map(string)
  default = {
    "ap-northeast-1" = "com.amazonaws.vpce.ap-northeast-1.vpce-svc-02aa633bda3edbec0"
    "ap-northeast-2" = "com.amazonaws.vpce.ap-northeast-2.vpce-svc-0dc0e98a5800db5c4"
    "ap-south-1"     = "com.amazonaws.vpce.ap-south-1.vpce-svc-03fd4d9b61414f3de"
    "ap-southeast-1" = "com.amazonaws.vpce.ap-southeast-1.vpce-svc-0557367c6fc1a0c5c"
    "ap-southeast-2" = "com.amazonaws.vpce.ap-southeast-2.vpce-svc-0b4a72e8f825495f6"
    "ca-central-1"   = "com.amazonaws.vpce.ca-central-1.vpce-svc-0c4e25bdbcbfbb684"
    "eu-central-1"   = "com.amazonaws.vpce.eu-central-1.vpce-svc-08e5dfca9572c85c4"
    "eu-west-1"      = "com.amazonaws.vpce.eu-west-1.vpce-svc-09b4eb2bc775f4e8c"
    "eu-west-2"      = "com.amazonaws.vpce.eu-west-2.vpce-svc-05279412bf5353a45"
    "eu-west-3"      = "com.amazonaws.vpce.eu-west-3.vpce-svc-005b039dd0b5f857d"
    "sa-east-1"      = "com.amazonaws.vpce.sa-east-1.vpce-svc-0e61564963be1b43f"
    "us-east-1"      = "com.amazonaws.vpce.us-east-1.vpce-svc-00018a8c3ff62ffdf"
    "us-east-2"      = "com.amazonaws.vpce.us-east-2.vpce-svc-090a8fab0d73e39a6"
    "us-west-2"      = "com.amazonaws.vpce.us-west-2.vpce-svc-0158114c0c730c3bb"
  }
}

variable "region_bucket_name" {
  description = "Name of the AWS region. (e.g. virginia)"
  type        = map(string)
  default = {
    "ap-northeast-1" = "tokyo"
    "ap-northeast-2" = "seoul"
    "ap-south-1"     = "mumbai"
    "ap-southeast-1" = "singapore"
    "ap-southeast-2" = "sydney"
    "ca-central-1"   = "montreal"
    "eu-central-1"   = "frankfurt"
    "eu-west-1"      = "ireland"
    "eu-west-2"      = "london"
    "eu-west-3"      = "paris"
    "sa-east-1"      = "saopaulo"
    "us-east-1"      = "virginia"
    "us-east-2"      = "ohio"
    "us-west-2"      = "oregon"
    # "us-west-1"      = "oregon"
  }
}