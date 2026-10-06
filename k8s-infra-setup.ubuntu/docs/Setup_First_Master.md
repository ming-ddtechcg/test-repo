# Setup the first master node

For setting up a first master node with the following instruction:

```bash
cd ~/k8s-infra-setup.ubuntu/bin
./cluster_setup.sh
```

The following is the console output for:

1. using cri-o for the CRI
2. no SAN

```
cd ~/k8s-infra-setup.ubuntu/bin
./cluster_setup.sh
[sudo] password for <username>:

Is this the first master node (y/n): y
Select Container Runtime Interface (CRI) runs on this node
==========================================================
1. CRI-O
2. containerd
3. cri-docker/docker

9. terminate the cluster setup


select (1/2/3/9): 1

Enter Virtual IP (VIP) or Load Balancer (LB) IP address and DNS name (FQDN) with the apiserver listen port number
(press enter to ignore)
:

Enter extra subjcet alernative name(s) for certifcats to access the api-server
(press enter to ignore, use comma between each SAN)
: 

the current node type: NONE

perform the first master setup now...
setup the first master node

[init] Using Kubernetes version: v1.36.5
[preflight] Running pre-flight checks
[preflight] Pulling images required for setting up a Kubernetes cluster
[preflight] This might take a minute or two, depending on the speed of your internet connection
[preflight] You can also perform this action beforehand using 'kubeadm config images pull'
W1005 15:06:58.119856  299879 checks.go:907] detected that the sandbox image "registry.k8s.io/pause:3.10.1" of the container runtime is inconsistent with that used by kubeadm. It is recommended to use "registry.k8s.io/pause:3.10.2" as the CRI sandbox image.
[certs] Using certificateDir folder "/etc/kubernetes/pki"
[certs] Generating "ca" certificate and key
[certs] Generating "apiserver" certificate and key
[certs] apiserver serving cert is signed for DNS names [kubee-mnt1-ubuntu-2204 kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local] and IPs [10.96.0.1 192.168.131.20]
[certs] Generating "apiserver-kubelet-client" certificate and key
[certs] Generating "front-proxy-ca" certificate and key
[certs] Generating "front-proxy-client" certificate and key

...

[addons] Applied essential addon: CoreDNS
[addons] Applied essential addon: kube-proxy

Your Kubernetes control-plane has initialized successfully!

...

```

## Add-ons

The first time setup is required Container Network Interface (CNI), please check the add-ons section.

