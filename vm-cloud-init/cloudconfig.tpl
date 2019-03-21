#include https://get.docker.com

#cloud-config
apt:
  preserve_sources_list: true
  sources:
    azure-cli.list:
      source: "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ xenial main"
      keyid: BC528686B50D79E339D3721CEB3E94ADBE1229CF
      keyserver: packages.microsoft.com
package_upgrade: true
packages:
  - apt-transport-https
  - lsb-release
  - software-properties-common
  - dirmngr
  - azure-cli

runcmd:
 - echo "Hello ${hello_world_text}! Created by Azure terraform-vmss-cloudinit module." | sudo dd of=/tmp/terraformtest &> /dev/null