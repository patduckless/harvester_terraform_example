resource "harvester_virtualmachine" "terrafrom-test-vm" {
  # This section generates the name dynamically based on a variable and the count of the VM. Allowing for the deployment of many copies simultaneously. 
  name                 = "${var.environment_short}VM${format("%02d", count.index + 1)}"
  namespace            = "default"
  restart_after_update = true
  description          = "VM to test deployment to Harvester via terraform."
  count                = 2

  tags = {
    ssh-user = "patduckless"
  }

  cpu    = local.terrafrom-test-vm.cpu
  memory = local.terrafrom-test-vm.memory

  efi         = true
  secure_boot = true

  run_strategy    = "RerunOnFailure"
  hostname        = "${var.environment_short}VM${format("%02d", count.index + 1)}"
  machine_type    = "q35"

  network_interface {
    name           = "${var.environment_short}VM${format("%02d", count.index + 1)}-nic-1"
    network_name   = "default/vlan1"
  }

  disk {
    name       = "${var.environment_short}VM${format("%02d", count.index + 1)}-root-disk"
    type       = "disk"
    size       = "20Gi"
    bus        = "virtio"
    boot_order = 1
    # The image comes from the ID of the image in the harvester UI. Took me way too long to figure that part out. :(
    image       = "default/image-ng66c"
    auto_delete = true
  }

  cloudinit {
    user_data    = <<-EOF
      #cloud-config
      users:
        - name: patduckless
          passwd: "Tm90IG15IHJlYWwgcGFzc3dvcmQsIGJ1dCBuaWNlIHRyeSE="
          groups: sudo
          shell: /bin/bash
          lock_passwd: false
          ssh_pwauth: true
          ssh_authorized_keys:
            - >-
              "ssh-rsa <redacted>"
      package_update: true
      packages:
        - qemu-guest-agent
      runcmd:
        - - systemctl
          - enable
          - '--now'
          - qemu-guest-agent
      EOF
  }
}