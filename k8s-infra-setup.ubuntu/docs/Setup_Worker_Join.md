# Setup the worker node join

For setting up a worker node join with the following instruction:

```bash
cd ~/k8s-infra-setup.ubuntu/bin
./cluster_setup.sh
```

The following is the setup requriements for:

1. using cri-o for the CRI (cri-o is an example for this setup).
2. CNI setup is completed.

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

and, the print join command is required to be generated at the master node:

```
$ ./print_worker_join_command.sh
print the worker join command

Is this the master node and the cluster is running (y/n): y
Select Container Runtime Interface (CRI) runs on the targetd node
=================================================================
1. CRI-O
2. containerd
3. cri-docker/docker

9. exit


select (1/2/3/9): 1

the worker node join command: 

kubeadm join 192.168.131.20:6443 ... --cri-socket unix:///var/run/crio/crio.sock

please copy the above kubernetes worker join command to the desired node and execute it.

completed the worker join print command
```

copy "kubeadm join 192.168.131.20:6443 ... --cri-socket unix:///var/run/crio/crio.sock" and paste over to the console of the working on node, then continue the following setup:

```
$ ./cluster_setup.sh

Is this the first master node (y/n): n

For master join, run "print_master_join_command.sh" at the first master node

For worker join, run "print_worker_join_command.sh" at the first master node

Waiting this node to be joined
paste kubeadm join here: kubeadm join 192.168.131.20:6443 ... --cri-socket unix:///var/run/crio/crio.sock
[preflight] Running pre-flight checks
[preflight] Reading configuration from the "kubeadm-config" ConfigMap in namespace "kube-system"...
[preflight] Use 'kubeadm init phase upload-config kubeadm --config your-config-file' to re-upload it.
W1005 17:35:57.067693    6243 utils.go:69] The recommended value for "bindAddress" in "KubeProxyConfiguration" is: ::; the provided value is: 0.0.0.0
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/instance-config.yaml"
[patches] Applied patch of type "application/strategic-merge-patch+json" to target "kubeletconfiguration"
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Starting the kubelet
[kubelet-check] Waiting for a healthy kubelet at http://127.0.0.1:10248/healthz. This can take up to 4m0s
[kubelet-check] The kubelet is healthy after 2.011231988s
[kubelet-start] Waiting for the kubelet to perform the TLS Bootstrap

This node has joined the cluster:
* Certificate signing request was sent to apiserver and a response was received.
* The Kubelet was informed of the new secure connection details.

Run 'kubectl get nodes' on the control-plane to see this node join the cluster.
```
