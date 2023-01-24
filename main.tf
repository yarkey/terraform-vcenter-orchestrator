provider "vsphere" {
  user                 = var.vcenter_user
  password             = var.vcenter_password
  vsphere_server       = var.vcenter_server
  allow_unverified_ssl = true
}

terraform {
  required_providers {
    vsphere = {
      source = "local/hashicorp/vsphere"
    }
  }
}

locals {
  networks = merge([
    for vm_key, objects in var.virtual_machines : {
      for interface in objects.interfaces : 
        "${vm_key}-${interface.ipv4_address}"  => {   
          network           = interface.network
          ipv4_address = interface.ipv4_address
          ipv4_netmask  = interface.ipv4_netmask
      }
  }]...)
}

data "vsphere_datacenter" "dc" {
  name = var.vcenter_datacenter
}

data "vsphere_datastore" "datastore" {
  for_each	= var.virtual_machines
  name          = each.value.datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "pool" {
  for_each	= var.virtual_machines
  name          = each.value.resource_pool
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "interfaces" {
  for_each      = local.networks
  name          = each.value.network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  for_each	= var.virtual_machines
  name          = each.value.template
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "vm" {
  for_each         = var.virtual_machines
  
  name             = "${var.prefix}-${each.key}.${each.value.domain_name}"
  # resource_pool_id = data.vsphere_resource_pool.pool.id
  resource_pool_id  = data.vsphere_resource_pool.pool[each.key].id
  datastore_id     = data.vsphere_datastore.datastore[each.key].id

  num_cpus         = each.value.num_cpus
  memory           = each.value.memory
  guest_id         = data.vsphere_virtual_machine.template[each.key].guest_id

  disk {
    label            = "disk0"
    size             = data.vsphere_virtual_machine.template[each.key].disks[0].size
    thin_provisioned = data.vsphere_virtual_machine.template[each.key].disks[0].thin_provisioned
  }

  dynamic "network_interface" {
    for_each        = each.value.interfaces
    content{
      network_id    = data.vsphere_network.interfaces["${each.key}-${network_interface.value.ipv4_address}"].id
    }
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template[each.key].id

    customize {
      linux_options {
        host_name = each.key
        domain    = each.value.domain_name
      }

      dynamic "network_interface" {
        for_each        = each.value.interfaces

        content {
          ipv4_address = network_interface.value.ipv4_address
          ipv4_netmask = network_interface.value.ipv4_netmask
        }
      }
	 
      ipv4_gateway    = each.value.gateway
      dns_server_list = each.value.dns_server_list
    }
  }
}

