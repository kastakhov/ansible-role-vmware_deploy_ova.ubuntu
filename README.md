# Ansible

Download OVA (Default: Ubuntu Noble) file from the internet and deploy it as VM in VMWare vCenter.

## Preparing

1. Clone repository to your local machine
2. Open repository directory and run prepare-environment.pl, like next

    ```shell
    ./prepare-environment.pl
    ```

3. When environment will be ready you will see *Virtual environment successfully prepeared.* in console
4. Run playbook with run_playbook.sh script, like next

    ```shell
    ./run_playbook.sh -i inventory/<inventory file> deploy-ubuntu-vm.yml
    ```

    Note: With `--extra-vars vm_redeploy=true` if VM already exists, it'll be removed and the new VM deployed.

## Playbook variables

### VM Details and parameters

1. Copy `roles/vmware.ubuntu-ova/vars/local-vars.yml.tmpl` as `roles/vmware.ubuntu-ova/vars/local-vars.yml`

2. Edit `roles/vmware.ubuntu-ova/vars/local-vars.yml` with your favorite editor (like nano or vim) and adjust values inside quotes

### Credentials to vSphere server

1. Copy `roles/vmware.ubuntu-ova/vars/local-vmware.yml.tmpl` as `roles/vmware.ubuntu-ova/vars/local-vmware.yml`

2. Edit `roles/vmware.ubuntu-ova/vars/local-vmware.yml` with your favorite editor (like nano or vim) and adjust values inside quotes.
