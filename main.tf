terraform {
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = ">= 2.0.0"
    }
  }
}

provider "vsphere" {
  user                  = var.vm_username
  password              = var.vm_password
  vsphere_server        = var.vsphere_server
  allow_unverified_ssl  = true
}

data "vsphere_datacenter" "dc" {
  name = var.vsphere_datacenter
}

data "vsphere_compute_cluster" "compute_cluster" {
  name          = var.vsphere_compute_cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = var.network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.template
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_host" "selected_host" {
  name          = var.selected_host
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "selected_datastore" {
  count         = length(local.accessible_datastores) > 0 ? 1 : 0
  name          = local.accessible_datastores[0]
  datacenter_id = data.vsphere_datacenter.dc.id

  # Fail gracefully if the datastore does not exist
  depends_on = [data.vsphere_host.selected_host]
}

data "external" "highest_ip_suffix" {
  program = ["bash", "get_highest_ip_suffix.sh"]
}

data "external" "highest_hostname_prefix" {
  program = ["bash", "get_highest_hostname_prefix.sh"]
}

data "external" "highest_vm_name_prefix" {
  program = ["bash", "get_highest_vm_name_prefix.sh"]
}
data "vsphere_tag_category" "existing_category" {
  name = "Kubernetes"  # Replace with your desired category name
}

locals {
  target_vm_count = var.current_vm_count + var.increment
  highest_ip_suffix       = tonumber(trimspace(data.external.highest_ip_suffix.result["output"])) + 1
  highest_hostname_prefix = trimspace(data.external.highest_hostname_prefix.result["output"])
  highest_vm_name_prefix  = trimspace(data.external.highest_vm_name_prefix.result["output"])

  workernodes = [
    for idx in range(0, local.target_vm_count) : {
      hostname   = "${local.highest_hostname_prefix}${local.highest_ip_suffix + idx}",
      ip_address = "172.28.8.${local.highest_ip_suffix + idx}"
    }
  ]

  vmnames = [
    for idx in range(0, local.target_vm_count) : {
      name  = "worker${idx + 1}_name",
      value = "${local.highest_vm_name_prefix}${local.highest_ip_suffix + idx}"
    }
  ]

  accessible_datastores = try(var.host_datastore_map[var.selected_host], [])
  existing_category_name = data.vsphere_tag_category.existing_category.name
  new_category_name      = length(local.existing_category_name) > 0 ? "${local.existing_category_name}-1" : "Kubernetes"
}

resource "vsphere_virtual_machine" "vms" {
  #count = var.vm_count
  count = local.target_vm_count

  name             = "${local.highest_vm_name_prefix}${local.highest_ip_suffix + count.index}"
  resource_pool_id = data.vsphere_compute_cluster.compute_cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.selected_datastore[0].id
  folder           = "Kubernetes"

  num_cpus = 2
  memory   = 4096
  guest_id = "ubuntu64Guest"

  disk {
    label            = "disk0"
    size             = "100"
    thin_provisioned = true
  }

  connection {
    type     = "ssh"
    user     = "test"
    password = "Welcome@123"
    host     = self.default_ip_address
  }

  provisioner "file" {
    source      = var.idrsa_pub
    destination = "/tmp/authorized_keys"
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p ~/.ssh",
      "cat /tmp/authorized_keys >> ~/.ssh/authorized_keys",
      "chmod 600 ~/.ssh/authorized_keys",
      "chmod 700 ~/.ssh",
    ]
  }

  network_interface {
    network_id = data.vsphere_network.network.id
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
    customize {
      linux_options {
        host_name = "${local.highest_hostname_prefix}${local.highest_ip_suffix + count.index}"
        domain    = ""
      }

      network_interface {
        ipv4_address = "172.28.8.${local.highest_ip_suffix + count.index}"
        ipv4_netmask = 24
      }

      ipv4_gateway    = var.vm_ipv4_gateway
      dns_server_list = ["8.8.8.8", "8.8.4.4"]
    }
  }

  host_system_id = data.vsphere_host.selected_host.id
}

resource "local_file" "inventory" {
  content = join("\n\n", [
    templatefile("inventory.tpl", {
      worker_nodes = local.workernodes,
      vmnames      = local.vmnames,
  }),
    templatefile("additional_inventory.tpl", {
      idrsa = var.idrsa
    })
  ])

  filename = "ansible/inventory.ini"
}

resource "vsphere_tag_category" "category" {
  count            = length(local.new_category_name) > 1 ? 0 : 1
  name             = local.new_category_name
  description      = "Category for Kubernetes VMs"
  cardinality      = "MULTIPLE"
  associable_types = ["VirtualMachine"]
}

resource "vsphere_tag" "worker" {
  count       = length(data.vsphere_tag_category.existing_category) > 0 ? length(vsphere_tag_category.category) : 0
  name        = "worker${count.index + 1}"
  category_id = vsphere_tag_category.category[count.index].id
}

output "datastore_id" {
  value = length(data.vsphere_datastore.selected_datastore) > 0 ? data.vsphere_datastore.selected_datastore[0].id : null
}

