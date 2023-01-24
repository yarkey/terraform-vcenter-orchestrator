# Replace with your own values
virtual_machines = {
  "vm1" = {
    resource_pool   = "esx01-main-pool"
    datastore       = "esx01-ds1"
    template        = "temp-centos7"
    host_name       = "vm1"
    domain_name     = "contoso.com"
    dns_server_list = ["8.8.8.8", "8.8.4.4"]
    num_cpus        = 2
    memory          = 2048
    interfaces      = [
      {
      ipv4_address  = "192.168.5.1"
      ipv4_netmask  = "24"
      network       = "vlan2"
      },
      {
      ipv4_address  = "10.10.0.1"
      ipv4_netmask  = "24"
      network       = "wan-isp1"
      }
    ]
    gateway         = "192.168.5.100"
  }


  "vm2" = {
    resource_pool   = "esx02-main-pool"
    datastore       = "esx02_ds1"
    template        = "temp-centos7"
    host_name       = "vm2"
    domain_name     = "contoso.com"
    dns_server_list = ["8.8.8.8", "8.8.4.4"]
    num_cpus        = 2
    memory          = 4096
    interfaces      = [
      {
      ipv4_address  = "10.10.0.2"
      ipv4_netmask  = "24"
      network       = "vlan2"
      }
    ]
    gateway         = "192.158.5.100"
  }
	
}

