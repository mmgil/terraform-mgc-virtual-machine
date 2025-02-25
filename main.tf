locals {
  resource_name_partial        = substr(var.project_name, 0, length(var.project_name) - 3)
  resource_name                = "${replace(local.resource_name_partial, "mgc", "vm")}${format("%03d", var.sequence)}"
  resource_name_disk           = "${local.resource_name}-disk"
  resource_name_ip_publico     = "${local.resource_name}-pip"
  resource_name_security_group = "${local.resource_name}-secgroup"

  ## - PUBLIC IP
  public_ips = flatten(
    [
      for k1, v1 in var.nic : [
        for k2, v2 in v1.public_ips : {
          nic_key       = k1
          public_ip_key = k2
          vpc_id        = v1.vpc_id == null ? var.vpc_id : v1.vpc_id
          description   = v2.description
        } if v2 != null || v2.enabled
      ] if v1.enabled
    ]
  )

  ## - SECURITY GROUPS
  security_groups = flatten(
    [
      for k1, v1 in var.nic : [
        for k2, v2 in v1.security_groups : {
          nic_key               = k1
          security_group_key    = k2
          vpc_id                = v1.vpc_id == null ? var.vpc_id : v1.vpc_id
          description           = v2.description
          disable_default_rules = v2.disable_default_rules
        } if v2.enabled
      ] if v1.enabled
    ]
  )

  rules = flatten(
    [
      for k1, v1 in var.nic : [
        for k2, v2 in v1.security_groups : [
          for k3, v3 in v2.rules : {
            nic_key            = k1
            security_group_key = k2
            rule_key           = k3
            description        = v3.description
            direction          = v3.direction
            ethertype          = v3.ethertype
            port_range_max     = v3.port_range_max
            port_range_min     = v3.port_range_min
            protocol           = v3.protocol
            remote_ip_prefix   = v3.remote_ip_prefix
          } if v3.enabled
        ] if v2.enabled
      ] if v1.enabled
    ]
  )
}

#####################
## - GET REQUIREMENTS
data "mgc_availability_zones" "availability_zones" {}

#####################
## - RESOURCES

## - INTERFACE
resource "mgc_network_vpcs_interfaces" "nic" {
  for_each = { for k, v in var.nic : k => v if v.enabled }

  name   = "${local.resource_name}-${each.key}"
  vpc_id = each.value.vpc_id == null ? var.vpc_id : each.value.vpc_id
}

## - IP PUBLICO
resource "mgc_network_public_ips" "pip" {
  for_each = { for v in local.public_ips : format("%s-%s", v.nic_key, v.public_ip_key) => v }

  description = each.value.description
  vpc_id      = each.value.vpc_id
}

resource "mgc_network_public_ips_attach" "pip" {
  for_each = { for k, v in local.public_ips : format("%s-%s", v.nic_key, v.public_ip_key) => v }

  public_ip_id = mgc_network_public_ips.pip[each.key].id
  interface_id = mgc_network_vpcs_interfaces.nic[each.value.nic_key].id
}

## - SECURITY GROUPS
resource "mgc_network_security_groups" "secgroup" {
  for_each = { for v in local.security_groups : format("%s-%s", v.nic_key, v.security_group_key) => v }

  name                  = "${local.resource_name_security_group}-${each.key}"
  description           = each.value.description
  disable_default_rules = each.value.disable_default_rules
}

resource "mgc_network_security_groups_rules" "rules" {
  for_each = { for v in local.rules : format("%s-%s-%s", v.nic_key, v.security_group_key, v.rule_key) => v }

  description       = each.value.description
  direction         = each.value.direction
  ethertype         = each.value.ethertype
  port_range_max    = each.value.port_range_max
  port_range_min    = each.value.port_range_min
  protocol          = each.value.protocol
  remote_ip_prefix  = each.value.remote_ip_prefix
  security_group_id = mgc_network_security_groups.secgroup[format("%s-%s", each.value.nic_key, each.value.security_group_key)].id
}

resource "mgc_network_security_groups_attach" "attach" {
  for_each = { for k, v in local.security_groups : format("%s-%s", v.nic_key, v.security_group_key) => v }

  security_group_id = mgc_network_security_groups.secgroup[each.key].id
  interface_id      = mgc_network_vpcs_interfaces.nic[each.value.nic_key].id
}

## - VM INSTANCE
resource "mgc_ssh_keys" "key" {
  count = var.image != "windows-server-2022" ? 1 : 0

  name = "m1cloud"
  key  = var.ssh_key
}

resource "mgc_virtual_machine_instances" "vm" {
  availability_zone = var.availability_zone
  image             = var.image
  machine_type      = var.machine_type
  name              = local.resource_name
  ssh_key_name      = var.image != "windows-server-2022" ? mgc_ssh_keys.key.0.name : null
  user_data         = null
  vpc_id            = var.vpc_id
}

resource "mgc_virtual_machine_interface_attach" "attach_vm" {
  for_each = { for k, v in var.nic : k => v if v.enabled }

  instance_id  = mgc_virtual_machine_instances.vm.id
  interface_id = mgc_network_vpcs_interfaces.nic[each.key].id
}

## - ARMAZENAMENTO
resource "mgc_block_storage_volumes" "storage" {
  for_each = { for k, v in var.storage : k => v if v.enabled }

  name              = "${local.resource_name_disk}-${each.key}"
  size              = each.value.size
  type              = each.value.type
  availability_zone = var.availability_zone
  encrypted         = each.value.encrypted
  snapshot_id       = each.value.snapshot_id
}

resource "mgc_block_storage_volume_attachment" "attach" {
  for_each = { for k, v in var.storage : k => v if v.enabled }

  block_storage_id   = mgc_block_storage_volumes.storage[each.key].id
  virtual_machine_id = mgc_virtual_machine_instances.vm.id
}