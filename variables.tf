variable "vm_username" {
  description = "Username for vSphere provider"
  type        = string
}

variable "vm_password" {
  description = "Password for vSphere provider"
  type        = string
}

variable "vsphere_server" {
  description = "vSphere server address"
  type        = string
}

variable "vsphere_datacenter" {
  description = "Name of the vSphere datacenter"
  type        = string
}

variable "vsphere_compute_cluster" {
  description = "Name of the vSphere compute cluster"
  type        = string
}

variable "network" {
  description = "Name of the network to attach VMs"
  type        = string
}

variable "template" {
  description = "Name of the VM template to clone"
  type        = string
}

variable "selected_host" {
  description = "Name of the selected host for VM deployment"
  type        = string
}

variable "idrsa" {
  description = "Path to the public key file"
  type        = string
  default     = "id_rsa.pub"
}

variable "idrsa_pub" {
  description = "Path to the public key file (.pub)"
  type        = string
  default     = "id_rsa.pub"
}

variable "vm_ipv4_gateway" {
  description = "IPv4 gateway for VMs"
  type        = string
  default     = "172.28.8.1"
}

variable "host_datastore_map" {
  type        = map(list(string))
  description = "Map of hosts to their accessible datastores"
  default     = {
    "172.28.8.2" = ["Local-2.1"],
    "172.28.8.3" = ["Local-3.0"],
    "172.28.8.4" = ["Local-4.0"]
  }
}
variable "current_vm_count" {
  description = "The current number of VMs in the cluster"
  type        = number
  default     = 0
}

variable "increment" {
  description = "The number of VMs to add"
  type        = number
  default     = 2
}

variable "workernode_inventory" {
  type = list(object({
    vm_name_prefix     = string
    vm_hostname_prefix = string
    ip_base            = string
  }))
  description = "List of worker node configurations"
  default = [
    {
      vm_name_prefix     = "worker-node-"
      vm_hostname_prefix = "worker"
      ip_base            = "172.28.8.0"
    }
  ]
}

