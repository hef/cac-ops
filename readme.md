
Creating a kubernetes cluster on Cloud at Cost

## Bootstrapping

Build servers
```shell
repeat 20 { cacctl build --cpu 4 --ram 8192 --storage 80 }
```

Regenerate hosts.yml file for ansible
```shell
cacctl ansible-inventory > provision/ansible/inventory/hosts.yml
```

Deploy your ssh key to all servers
```shell
cacctl ssh-copy-id
```

Run task commands to provision everything
```shell
task ansible:playbook:ubuntu-upgrade
task ansible:playbook:ubuntu-prepare
task ansible:playbook:cac-fixdisk
task ansible:playbook:k3s-install
```

Edit provision/kubeconfig to point to your cluster

Bootstrap flux
```shell
export SOPS_AGE_KEY_FILE=~/.config/sops/age/cac.agekey
task flux:secret
task flux:bootstrap
```

Generate a new kube config:
```shell
task newconfig
```

Diff the new config with the old one. If you are satisfied with the new config, run the following command:
```shell
mv ~/.kube/newconfig ~/.kube/config
```

## Bootstrapping Vault

Initializing vault takes some extra steps
You will need to run each unseal command 3 times for each pod.

```shell
 kubectl exec -ti vault-0 -n vault -- vault operator init
 kubectl exec -ti vault-0 -n vault -- vault operator unseal
```

```shell
kubectl exec -ti vault-1 -n vault -- vault operator raft join http://vault-0.vault-internal:8200
kubectl exec -ti vault-1 -n vault -- vault operator unseal
```

```shell
kubectl exec -ti vault-2 -n vault -- vault operator raft join http://vault-0.vault-internal:8200
kubectl exec -ti vault-2 -n vault -- vault operator unseal
```

## Enabling Image Update Automation
```shell
kubectl create secret generic -n flux-system flux-system --from-literal=username=git --from-literal=password=<github pat with repo scope>
```
