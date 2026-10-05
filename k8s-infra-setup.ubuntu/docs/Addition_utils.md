# Additional utilities related the cluster setup

## worker labeling

When a new non-master node joined into the cluster, the labeling will always be absent for the newly added worker node. Likes:

```
$ kubectl get nodes
NAME                     STATUS   ROLES           AGE    VERSION
kubee-mnt1-ubuntu-2204   Ready    control-plane   121m   v1.36.5
kubee-mnt2-ubuntu-2204   Ready    control-plane   87m    v1.36.5
kubee-wnt1-ubuntu-2204   Ready    <none>          8m8s   v1.36.5
```

The node "kubee-wnt1-ubuntu-2204" is an example.

A utility "called label_all_worker_nodes.sh", under "~/k8s-infra-setup.ubuntu/utils" to label it as "worker":

```bash
cd ~/k8s-infra-setup.ubuntu/utils
./label_all_worker_nodes.sh
```

the above step will search all nodes and label "node-role.kubernetes.io/worker=" for the role has been set.

Result:

```
$ kubectl get nodes
NAME                     STATUS   ROLES           AGE    VERSION
kubee-mnt1-ubuntu-2204   Ready    control-plane   129m   v1.36.5
kubee-mnt2-ubuntu-2204   Ready    control-plane   95m    v1.36.5
kubee-wnt1-ubuntu-2204   Ready    <none>          16m    v1.36.5
```
