# Overview

This Ansible role designed for deploying Ubuntu OVAs from the official Ubuntu repository.

You have to set all variables listed in `defaults/main.yml` file. By default the `Noble` release is used.

This role tested with ansible 2.15, 2.16, 2.17.

You have to install the `community.vmware` collection as well as python3 libs required by this collection.

In general the next steps will be performed:

* The latest OVA image will be download locally
* The VM existense will be checked and in case of `vm_redeploy` variable set to `true`, the current VM will be removed
* The VM folder will be created and OVA will be deployed into this folder
* The new VM parameters will be changed respectively to the provided configuration
* At the end of deployment the VM details will be printed

## Role Defaults

### vSphere connection settings

* vmware_vc_url - (string) vSphere IP or FQDN
* vmware_validate_certs - (bool) validation vSphere SSL
* vmware_dc - (string) vSphere DataCenter to which VM need to be deployed
* vmware_cluster - (string) vSphere cluster to which VM need to be deployed
* vmware_vm_datastore - (string) host datastore to which VM need to be deployed
* vmware_vc_user - (string) vSphere username
* vmware_vc_password - (string) vSphere password#
  
### VM location

* vmware_vm_parrent_folder - (string) Parrent folder, might be empty in case of vmware_vm_folder is the top folder
* vmware_vm_folder - (string) Actual folder to which the VM will be deployed
* vm_hostname - (string) VM hostname and VM name in ESXi

### VM configuration

* vmware_vm_network_label - (string) Network label
* vm_ram_size - (integer) RAM size, in Gb
* vm_cpu_count - (integer) the number of the VM CPUs
* vm_cpu_per_socket - (integer) the number of the VM CPUs per Socket
* vm_disk_size - (integer) Disk size, in Gb

### VM Customization

* cloud_image_version_name - (string) Ubuntu code name (default: noble)
* vm_redeploy - (bool) If true, VM will be deleted before deployment (check by the VM name)
* vm_public_key - (string) SSH public key for the `ubuntu` user
* vm_packages_to_install - (list of stings) List of packages which need to be installed
* vm_time_zone - (string) VM Time Zone
* vm_custom_files - (list of dicts) You can create new files with it
* vm_user_data - (string) Whole cloud-config with will be passed inside VM
