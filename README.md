
<!-- LOGO -->
<a name="readme-top"></a>
<br />

<div align="center">
  <a style="text-align: center" href="https://github.com/yarkey">
    <img align="center" src="https://github.com/yarkey/gitignore/blob/main/img/yarkey-logo-black.png?raw=true" alt="Logo" width="200" height="200">
  </a>
</div>

<div>

<h3 align="center">Simple Terraform Setup for vCenter Orchestration</h3>

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about">About</a>
    </li>
    <li>
      <a href="#Usage">Usage</a>
    </li>
    <li><a href="#contact">Contact</a></li>
  </ol>
</details>



<!-- ABOUT -->
<a name="about"></a>
## About
<p align="center">
(It's my little cheat sheet for terraform usage with vCenter provider).
This is the simple terraform config for manage vCenter infrastructures. My 
workflow is very simple. I use terraform to deploy and fix actual state of all 
of my vm's(obviously, except of those whose condition it is problematic to 
restore again, Active Directory for example for some reasones).

This approach provides several advantages for me:

- Fully up-to-date information of infrastructure design;
- Easy to customize existing machines;
- Easy to add new machines;
- Easy to migrate;
- Easy to restore, cause all infrastructure is a code in gitlab repo with some 
  ansible scripts and docker containers. Thats why i have only a few VM templates.
</p>

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- Usage -->
<a name="Usage"></a>
## Usage

<details>
  <summary>Online initialisation.</summary>
  <ol>
  
  The first of all we need to prepare current directory to work with vSphere 
  provider.
  For online initialization(plugin will be downloaded automatically):
  
  ```shell
  terraform init
  ```
  </ol>
</details>

<details>
  <summary>Offline initialization.</summary>
  <ol>
  
  Sometimes there are problems with online initialization(for some reasons) 
  thats why i've put plugin and the little script to create config folder and 
  copy whis plugin there.
  
  Run 'local.sh' script to copy plugin:
  ```shell
  ./local.sh
  ```
  
  And then prepare working directory:
  ```shell
  terraform init
  ```
  </ol>
</details>

<details>
  <summary>vCenter information(vcenter.auto.tfvars file).</summary>
  <ol>
  
  vcenter.auto.tfvars contains credentials and address of our vcenter:
  
  ```shell
  vcenter_datacenter = "ContosoDatacenter"
  vcenter_user= "administrator@contoso.com"
  vcenter_password= "Passw@rd"
  vcenter_server= "192.168.1.257"
  ```
  
  In this example config i operate with infrastructure without cluster
  configuration, but it's easy to customise it to use with clusters.
  
  All we need is IP, DataCenter name, login and password. All of other 
  data are stored in VM config file **vm.auto.tfvars**.
  </ol>
</details>

<details>
  <summary>Variable structure(vars.tf file).</summary>
  <ol>
  
  Here we declare our variable structure of vm.auto.tfvars file(where we 
  specify configurations for our VMs) and vcenter.auto.tfvars where we specify 
  credentials for our vCenter.
  </ol>
</details>

<details>
  <summary>VM's configuration(vm.auto.tfvars file).</summary>
  <ol>
  
  In this file we customize VM configuration.
  
  ```shell
  virtual_machines = {
    "vm1" = {
      resource_pool     = "esx01-main-pool"
      datastore         = "esx01-ds1"
      template          = "temp-centos7"
      host_name         = "vm1"
      domain_name       = "contoso.com"
      dns_server_list   = ["8.8.8.8", "8.8.4.4"]
      num_cpus          = 2
      memory            = 2048
      interfaces = [
        {
        ipv4_address    = "192.168.5.1"
        ipv4_netmask    = "24"
        network         = "vlan2"
        },
        {
        ipv4_address    = "10.10.0.1"
        ipv4_netmask    = "24"
        network         = "wan-isp1"
        }
      ]
      gateway           = "192.168.5.100"
    }
  }
  ```
  
  I prefer to select host in non-cluster design by specity resource_pool 
  of chosen host. Also i specify datastore here. If i have, for example, test 
  environment with standalone host, i specify it in vcenter.autp.tfvars globaly.
  
  Remember not to use resourse_pool of one of the host with datastore from 
  another ;)
  
  In "interfaces" section we can specify as much as we want. With "one network" 
  design i specify "network" in vcenter.auto.tfvars file.

  </ol>
</details>

<details>
  <summary>Main config(main.tf file).</summary>
  <ol>

  Our primary entrypoint whith wich all resources are created.
  
  This block parses vm.auto.tfvars file for network information to add 
  multiple interfaces and customize them later in the code:
  
  ```shell
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
  
  data "vsphere_network" "interfaces" {
    for_each       = local.networks
    name            = each.value.network
    datacenter_id   = data.vsphere_datacenter.dc.id
  }
  ```
 
  Contructions with "for_each" get values from all of VM's variables("template" 
  in this example):
  
  ```shell
  data "vsphere_virtual_machine" "template" {
    for_each      = var.virtual_machines
    name          = each.value.template
    datacenter_id = data.vsphere_datacenter.dc.id
  }
  ```
 
  Then simply use it in resource creation block:
  
  ```shell
  template_uuid = data.vsphere_virtual_machine.template[each.key].id
  ```
  
  Example of multiple interface creation:
  
  ```shell
    dynamic "network_interface" {
    for_each        = each.value.interfaces
    content{
      network_id    = data.vsphere_network.interfaces["${each.key}-${network_interface.value.ipv4_address}"].id
    }
  }
  ```
 
  </ol>
</details>
<p align="right">(<a href="#readme-top">back to top</a>)</p>


<!-- CONTACT -->
<a name="contact"></a>
## Contact

Be free to contact me for all questions!

Roman Yarkey - r.yarkey@gmail.com



<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/github_username/repo_name.svg?style=for-the-badge
[contributors-url]: https://github.com/github_username/repo_name/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/github_username/repo_name.svg?style=for-the-badge
[forks-url]: https://github.com/github_username/repo_name/network/members
[stars-shield]: https://img.shields.io/github/stars/github_username/repo_name.svg?style=for-the-badge
[stars-url]: https://github.com/github_username/repo_name/stargazers
[issues-shield]: https://img.shields.io/github/issues/github_username/repo_name.svg?style=for-the-badge
[issues-url]: https://github.com/github_username/repo_name/issues
[license-shield]: https://img.shields.io/github/license/github_username/repo_name.svg?style=for-the-badge
[license-url]: https://github.com/github_username/repo_name/blob/master/LICENSE.txt
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://linkedin.com/in/linkedin_username
[product-screenshot]: images/screenshot.png
[Next.js]: https://img.shields.io/badge/next.js-000000?style=for-the-badge&logo=nextdotjs&logoColor=white
[Next-url]: https://nextjs.org/
[React.js]: https://img.shields.io/badge/React-20232A?style=for-the-badge&logo=react&logoColor=61DAFB
[React-url]: https://reactjs.org/
[Vue.js]: https://img.shields.io/badge/Vue.js-35495E?style=for-the-badge&logo=vuedotjs&logoColor=4FC08D
[Vue-url]: https://vuejs.org/
[Angular.io]: https://img.shields.io/badge/Angular-DD0031?style=for-the-badge&logo=angular&logoColor=white
[Angular-url]: https://angular.io/
[Svelte.dev]: https://img.shields.io/badge/Svelte-4A4A55?style=for-the-badge&logo=svelte&logoColor=FF3E00
[Svelte-url]: https://svelte.dev/
[Laravel.com]: https://img.shields.io/badge/Laravel-FF2D20?style=for-the-badge&logo=laravel&logoColor=white
[Laravel-url]: https://laravel.com
[Bootstrap.com]: https://img.shields.io/badge/Bootstrap-563D7C?style=for-the-badge&logo=bootstrap&logoColor=white
[Bootstrap-url]: https://getbootstrap.com
[JQuery.com]: https://img.shields.io/badge/jQuery-0769AD?style=for-the-badge&logo=jquery&logoColor=white
[JQuery-url]: https://jquery.com 
