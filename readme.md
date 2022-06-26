
Creating a kubernetes cluster on Cloud at Cost

## Bootstrapping

Build your servers by running this command 20 times

```shell
cacctl build --cpu 4 --ram 8192 --storage 80
```

regenerate host lines for ansible

```shell
cacctl ansible-inventory > provision/ansible/hosts.yml
```

deploy your ssh key to all servers
```shell
cacctl ssh-copy-id
```

run task commands to provision everything
```shell
task ansible:playbook:ubuntu-upgrade
task ansible:playbook:ubuntu-prepare
task ansible:playbook:cac-fixdisk
task ansible:playbook:k3s-install
```

edit provision/kubeconfig to point to your cluster

bootstrap flux
```shell
export SOPS_AGE_KEY_FILE=~/.config/sops/age/cac.agekey
task flux:secret
task flux:bootstrap
```

generate a new kube config:
```shell
task newconfig
```

diff the new config with the old one. If you are satisfied with the new config, run the following command:
```shell
mv ~/.kube/newconfig ~/.kube/config
```
