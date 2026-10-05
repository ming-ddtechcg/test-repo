# Setup the first master node with SANs

This is to setup the master node with SANs (Subject Alternative Names) for the apiserver(s) mainly.

For setting up a first master node with the following instruction:

```bash
cd ~/k8s-infra-setup.ubuntu/bin
./cluster_setup.sh
```

The following is the setup requirements:

1. using cri-o for the CRI
2. with SAN entries

For SAN, the following is an example of the SAN that is to simulate an external load balancer:

```
$ nslookup kubee-apiservert-ubuntu-2204.ddtechcg.com 
Server:         192.168.105.18
Address:        192.168.105.18#53

Name:   kubee-apiservert-ubuntu-2204.ddtechcg.com
Address: 192.168.131.29
```

and, the master node:

```
cd ~/k8s-infra-setup.ubuntu/utils
$ ./retrieve_host_ip.sh
192.168.131.20
```

The following is the console log of the installation:

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

Enter extra subjcet alernative name(s) for certifcats to access the api-server
(press enter to ignore, use comma between each SAN)
: kubee-apiservert-ubuntu-2204.ddtechcg.com,192.168.131.29

the current node type: NONE

perform the first master setup now...
setup the first master node

[init] Using Kubernetes version: v1.36.5
[preflight] Running pre-flight checks
[preflight] Pulling images required for setting up a Kubernetes cluster
[preflight] This might take a minute or two, depending on the speed of your internet connection
[preflight] You can also perform this action beforehand using 'kubeadm config images pull'
W1005 15:42:49.443772  303751 checks.go:907] detected that the sandbox image "registry.k8s.io/pause:3.10.1" of the container runtime is inconsistent with that used by kubeadm. It is recommended to use "registry.k8s.io/pause:3.10.2" as the CRI sandbox image.
[certs] Using certificateDir folder "/etc/kubernetes/pki"
[certs] Generating "ca" certificate and key
[certs] Generating "apiserver" certificate and key
[certs] apiserver serving cert is signed for DNS names [kubee-apiservert-ubuntu-2204.ddtechcg.com kubee-mnt1-ubuntu-2204 kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local] and IPs [10.96.0.1 192.168.131.20 192.168.131.29]
[certs] Generating "apiserver-kubelet-client" certificate and key

...

[addons] Applied essential addon: CoreDNS
[addons] Applied essential addon: kube-proxy

Your Kubernetes control-plane has initialized successfully!

...

```

hence:

The certifcations will be generated not only for its node IP address, but also for the SANs:

```
[certs] apiserver serving cert is signed for DNS names [kubee-apiservert-ubuntu-2204.ddtechcg.com kubee-mnt1-ubuntu-2204 kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local] and IPs [10.96.0.1 192.168.131.20 192.168.131.29]
```
