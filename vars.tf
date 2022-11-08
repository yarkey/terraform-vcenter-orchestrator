variable "vcenter_datacenter" {
}

variable "vcenter_datastore" {
}

variable "vcenter_pool" {
}

variable "templates" {
  default = null
} 

variable "prefix" {
  default = "terra"
}

variable "vcenter_user" {
}

variable "vcenter_password" {
}

variable "vcenter_server" {
}

variable "virtual_machines" {
  type = map(object({
        template	= string
	host_name       = string
        domain_name	= string
	num_cpus        = number
	memory          = number
	dns_server_list = list(string)
	gateway 	= string
	interfaces	= list(object({
	  network = string
	  ipv4_address = string
	  ipv4_netmask = string
	}))	 
  }))
}
