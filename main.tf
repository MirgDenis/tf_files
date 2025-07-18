terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

data "template_file" "user_data" {
  template = file("${path.module}/user_data.cfg")
  vars = {
    pub_key = "${var.pub_key}"
  }
}

resource "libvirt_network" "network" {
  name		= "terraform_net"
  addresses	= [var.cidr_block]
}

resource "libvirt_cloudinit_disk" "cloud_init" {
  name		= "cloud_init.iso"
  user_data	= data.template_file.user_data.rendered
}

resource "libvirt_volume" "image" {
  name   = "tf_image.qcow2"
  source = "file:///var/lib/libvirt/images/noble-server-cloudimg-amd64.img"
  format = "qcow2"
}

resource "libvirt_volume" "base" {
  count	= var.instance_count
  name = "vm-${count.index}.qcow2"
  base_volume_id = libvirt_volume.image.id
  size = 100 * 1024 * 1024 * 1024
}

resource "libvirt_domain" "vm" {
  count = var.instance_count
  name   = "vm-${count.index}"
  memory = 4096
  vcpu   = 2
  cloudinit = libvirt_cloudinit_disk.cloud_init.id

  disk {
    volume_id = libvirt_volume.base[count.index].id
  }

  network_interface {
    network_name = libvirt_network.network.name
    addresses = [cidrhost(var.cidr_block, count.index + 10)]
  }
}
