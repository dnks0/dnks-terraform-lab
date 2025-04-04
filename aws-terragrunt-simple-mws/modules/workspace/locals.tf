locals {
  availability_zones  = [
    data.aws_availability_zones.this.names[0],
    data.aws_availability_zones.this.names[1],
    data.aws_availability_zones.this.names[2]
  ]
}
