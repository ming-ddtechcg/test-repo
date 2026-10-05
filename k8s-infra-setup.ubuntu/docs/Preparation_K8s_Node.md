# K8s node infrastruture preparation

The preparation is to configure settings and install necessary packages:

```
$ ./k8s_installation.sh
[sudo] password for bda-master:

perform the infra package installation
backup /etc/security/limits.conf to /etc/security/limits.conf_20230228224916
root soft nproc 100000
root hard nproc 100000
root soft nofile 100000
root hard nofile 100000
backup /etc/sysctl.conf to /etc/sysctl.conf_20230228224916
fs.file-max = 1000000
fs.inotify.max_user_watches=100000
fs.inotify.max_user_instances=100000
net.bridge.bridge-nf-call-iptables=1
net.bridge.bridge-nf-call-ip6tables=1
net.ipv4.ip_forward=1
net.ipv6.conf.all.forwarding=1
backup /etc/modules.conf to /etc/modules.conf_20230228224916
cp: cannot stat '/etc/modules.conf': No such file or directory
br_netfilter

WRANING: one of configurations is changed and the reboot is required.


Please enter (y)es to reboot or (n)o for the delay of the reboot (y/n): y

please perform the manual reboot later.


check the docker installation on the current system

install the docker package

verify the docker package installation

WARNING: apt does not have a stable CLI interface. Use with caution in scripts.

docker.io/focal-updates,now 20.10.12-0ubuntu2~20.04.1 amd64 [installed]

enable and start the docker service

Grant bda-master to perform all docker CLI tasks (y/n): y

WARNING: it is required bda-master to log out and log in again


the docker installation is completed


the infra package installation is completed


perform the basic package installation

the basic package installation is completed


disable swap

perform the k8s package installation
deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main

WARNING: apt does not have a stable CLI interface. Use with caution in scripts.

kubeadm/kubernetes-xenial,now 1.21.4-00 amd64 [installed,upgradable to: 1.26.1-00]
kubectl/kubernetes-xenial,now 1.21.4-00 amd64 [installed,upgradable to: 1.26.1-00]
kubelet/kubernetes-xenial,now 1.21.4-00 amd64 [installed,upgradable to: 1.26.1-00]

the k8s package installation is completed

Connection to kube3-1 closed by remote host.
Connection to kube3-1 closed.
```
