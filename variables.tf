variable "pub_key" {
  description = "Public SSH key for VM"
}

variable "cidr_block" {
  type    = string
  default = "172.18.0.0/16"
}

variable "instance_count" {
  type    = number
  default = 3
}
