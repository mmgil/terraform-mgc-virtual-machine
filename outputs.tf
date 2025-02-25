output "resources" {
  value = {
    vm         = mgc_virtual_machine_instances.vm
    ssh_key    = mgc_ssh_keys.key
    public_ips = mgc_network_public_ips.pip
  }
}
