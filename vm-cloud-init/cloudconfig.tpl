#cloud-config
package_upgrade: true
runcmd:
 - echo "Hello ${hello_world_text}! Created by Azure terraform-vmss-cloudinit module." | sudo dd of=/tmp/terraformtest &> /dev/null