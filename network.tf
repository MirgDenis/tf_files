resource "libvirt_network" "network" {
  name          = "terraform_net"
  addresses     = [var.cidr_block]
}
