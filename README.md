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
