resource "libvirt_cloudinit_disk" "cloud_init" {
  name = "cloud_init-${count.index}.iso"
  count = var.instance_count
  user_data = templatefile(
    "${path.module}/templates/user_data.cfg",
    {
      pub_key = "${var.pub_key}"
      hostname = "vm-${count.index}"
    }
  )
}

resource "libvirt_volume" "base" {
  name = "base.qcow2"
  source = "file:///var/lib/libvirt/images/noble-server-cloudimg-amd64.img"
}

resource "libvirt_volume" "volume" {
  name = "vm-${count.index}.qcow2"
  count = var.instance_count
  base_volume_id = libvirt_volume.base.id
  size = 100 * 1024 * 1024 * 1024
  format = "qcow2"
}
