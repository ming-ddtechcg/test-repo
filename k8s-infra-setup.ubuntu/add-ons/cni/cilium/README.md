# cilium
Cilium is a networking, observability, and security solution with an eBPF-based dataplane.

## Installation

This repository provides the cilium installation with Helm.  For the ciluim installation with CLI, please refer the the references "Cilium Quick Installation".

## Notes

The cilium installation is recommended with two nodes at least due to the deployment "cilium-operator" with the setting of "hostNetwork=true" not allowing the two pods listen the same ports and the rule of podAntiAffinity. Likes:

```
$ kubectl get pods -n kube-system -o wide | grep "cilium-operator" 
cilium-operator-65857c7db4-5ct2g                 1/1     Running   0          11m    192.168.131.24   kubee-wnt2-ubuntu-2204   <none>           <none>
cilium-operator-65857c7db4-c4h6g                 1/1     Running   0          11m    192.168.131.22   kubee-mnt3-ubuntu-2204   <none>           <none>
```

## References

- [Networking and Network Policy](https://kubernetes.io/docs/concepts/cluster-administration/addons/#networking-and-network-policy)
- [Installation using Helm](https://docs.cilium.io/en/stable/installation/k8s-install-helm/)
- [Cilium Quick Installation](https://docs.cilium.io/en/stable/gettingstarted/k8s-install-default/#install-the-cilium-cli)

