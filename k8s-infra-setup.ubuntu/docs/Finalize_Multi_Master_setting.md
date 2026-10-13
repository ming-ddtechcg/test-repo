# Finalize Multi Master/Control plane Setup
This setup is to adjust the api-servers/ETCDs in the multi master/control plane nodes environment.

With the example in:

![Multik8s_v1.36.5_infrastructure_on_prem.PNG](k8s_v1.36.5_infrastructure_on_prem.PNG)

for the following adjustments that provided from the script:

1. the peer discovery for all ETCDs so that all ETCDs in different node can sync or be synced to/from other peers.
2. the communication between api-server and ETCD is not limited inside the node.  In other words, an api-servers can rearch an ETCD from another node as well.

