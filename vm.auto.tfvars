# Replace with your own values
virtual_machines = {
  "vm1" = {
    template = "Centos7-Template"
    host_name = "vm1"
    domain_name = "contoso.com"
    dns_server_list = ["8.8.8.8", "8.8.4.4"]
    num_cpus = 2
    memory = 2048
    interfaces = [
      {
      ipv4_address = "192.168.5.2"
      ipv4_netmask = "24"
      network = "External"
      },
      {
      ipv4_address = "10.10.0.1"
      ipv4_netmask = "24"
      network = "Internal"
      }
    ]
    gateway = "192.168.5.100"
  }


  "vm2" = {
    template = "Centos7-Template"
    host_name = "vm2"
    domain_name = "contoso.com"
    dns_server_list = ["8.8.8.8", "8.8.4.4"]
    num_cpus = 2
    memory = 4096
    interfaces = [
      {
      ipv4_address = "10.10.0.2"
      ipv4_netmask = "24"
      network = "Internal"
      }
    ]
    gateway = "10.10.0.1"
  }
	
}

