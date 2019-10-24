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
 - curl https://get.docker.com | bash
 - sudo usermod -aG docker ${admin_username}
 - wget https://github.com/wagoodman/dive/releases/download/v0.8.1/dive_0.8.1_linux_amd64.deb
 - sudo apt install ./dive_0.8.1_linux_amd64.deb
 - echo "Hello ${hello_world_text}! Created by Azure terraform-vmss-cloudinit module." | sudo dd of=/tmp/terraformtest &> /dev/null