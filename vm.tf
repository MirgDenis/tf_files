resource "libvirt_domain" "vm" {
  count = var.instance_count
  name   = "vm-${count.index}"
  memory = 4096
  vcpu   = 2
  cloudinit = libvirt_cloudinit_disk.cloud_init[count.index].id

  disk {
    volume_id = libvirt_volume.volume[count.index].id
  }

  network_interface {
    network_name = libvirt_network.network.name
    addresses = [cidrhost(var.cidr_block, count.index + 10)]
  }
}
