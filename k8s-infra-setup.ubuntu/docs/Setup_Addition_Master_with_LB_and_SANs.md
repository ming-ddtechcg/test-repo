# Setup the addition master node with LB and SANs

This is to setup the addition master node with LB (Load Balancer) and SANs (Subject Alternative Names), and the assumption is the first master node has been setup and running with LB and SANs.

For setting up an addition master node with the following instruction:

```bash
cd ~/k8s-infra-setup.ubuntu/bin
./cluster_setup.sh
```

The following is the setup requirements:

- using cri-o for the CRI (the CRI may not need to be matched the first master node. The example of setup will use cri-o same as the first master node).
- no LB and SANs is required for the addition node.

and, the master node:

```
cd ~/k8s-infra-setup.ubuntu/utils
$ ./retrieve_host_ip.sh
192.168.131.21
```

The following is the console log of the installation:

```
cd ~/k8s-infra-setup.ubuntu/bin
./cluster_setup.sh
[sudo] password for <username>:

Is this the first master node (y/n): n

For master join, run "print_master_join_command.sh" at the first master node

For worker join, run "print_worker_join_command.sh" at the first master node

Waiting this node to be joined
paste kubeadm join here: 
```

then, execute the following steps on the first master node to get the join command:

```bash
cd ~/k8s-infra-setup.ubuntu/bin
./print_master_join_command.sh
print the master join command

Is this the first master node (y/n): y
Select Container Runtime Interface (CRI) runs on the targetd node
=================================================================
1. CRI-O
2. containerd
3. cri-docker/docker

9. exit


select (1/2/3/9): 1

the master node join command: 

kubeadm join 192.168.131.20:6443 ... --control-plane --cri-socket unix:///var/run/crio/crio.sock

please copy the above kubernetes master join command to the desired node and execute it.

completed the master join print command
```

copy "kubeadm join 192.168.131.20:6443 ... --control-plane --cri-socket unix:///var/run/crio/crio.sock", and paste on the working on console of the addition master node.

the log:

```
./cluster_setup.sh

Is this the first master node (y/n): n

For master join, run "print_master_join_command.sh" at the first master node

For worker join, run "print_worker_join_command.sh" at the first master node

Waiting this node to be joined
paste kubeadm join here: kubeadm join 192.168.131.20:6443 ... --control-plane --cri-socket unix:///var/run/crio/crio.sock
[preflight] Running pre-flight checks
[preflight] Reading configuration from the "kubeadm-config" ConfigMap in namespace "kube-system"...
[preflight] Use 'kubeadm init phase upload-config kubeadm --config your-config-file' to re-upload it.
W1005 16:16:09.940165  133416 utils.go:69] The recommended value for "bindAddress" in "KubeProxyConfiguration" is: ::; the provided value is: 0.0.0.0
[preflight] Running pre-flight checks before initializing the new control plane instance
[preflight] Pulling images required for setting up a Kubernetes cluster
[preflight] This might take a minute or two, depending on the speed of your internet connection
[preflight] You can also perform this action beforehand using 'kubeadm config images pull'
W1005 16:16:09.982161  133416 checks.go:907] detected that the sandbox image "registry.k8s.io/pause:3.10.1" of the container runtime is inconsistent with that used by kubeadm. It is recommended to use "registry.k8s.io/pause:3.10.2" as the CRI sandbox image.
[download-certs] Downloading the certificates in Secret "kubeadm-certs" in the "kube-system" Namespace
[download-certs] Saving the certificates to the folder: "/etc/kubernetes/pki"
[certs] Using certificateDir folder "/etc/kubernetes/pki"
[certs] Generating "front-proxy-client" certificate and key
[certs] Generating "etcd/server" certificate and key
[certs] etcd/server serving cert is signed for DNS names [kubee-mnt2-ubuntu-2204 localhost] and IPs [192.168.131.21 127.0.0.1 ::1]
[certs] Generating "etcd/peer" certificate and key
[certs] etcd/peer serving cert is signed for DNS names [kubee-mnt2-ubuntu-2204 localhost] and IPs [192.168.131.21 127.0.0.1 ::1]
[certs] Generating "apiserver-etcd-client" certificate and key
[certs] Generating "etcd/healthcheck-client" certificate and key
[certs] Generating "apiserver" certificate and key
[certs] apiserver serving cert is signed for DNS names [kubee-apiservert-ubuntu-2204 kubee-apiservert-ubuntu-2204.ddtechcg.com kubee-mnt2-ubuntu-2204 kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local] and IPs [10.96.0.1 192.168.131.21 192.168.131.29]

...

[control-plane-check] kube-scheduler is healthy after 38.537346ms
[control-plane-check] kube-controller-manager is healthy after 46.841071ms
[control-plane-check] kube-apiserver is healthy after 66.723116ms

This node has joined the cluster and a new control plane instance was created:

* Certificate signing request was sent to apiserver and approval was received.
* The Kubelet was informed of the new secure connection details.
* Control plane label and taint were applied to the new node.
* The Kubernetes control plane instances scaled up.

...

```

hence:

The addiiton master cert creation will generate the SANs certifcations same as the first master node:

```
[certs] apiserver serving cert is signed for DNS names [kubee-apiservert-ubuntu-2204 kubee-apiservert-ubuntu-2204.ddtechcg.com kubee-mnt2-ubuntu-2204 kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local] and IPs [10.96.0.1 192.168.131.21 192.168.131.29]
```
