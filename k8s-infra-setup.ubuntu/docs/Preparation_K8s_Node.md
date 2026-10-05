# K8s node infrastruture preparation
To prepare a new node for either the master or worker nodes

## Environment setup

```bash
cd ~/k8s-infra-setup.ubuntu/infra
./util_installation.sh
./ubuntu_tuning.sh
```

## Select a CRI (Container Runtime Interface)

The CRI installations (under ~/k8s-infra-setup.ubuntu/infra) are provided in this packages are:

| Name | Script | Comment|
| --- | --- | --- |
| cri-o | crio_installation.sh ||
| containerd | containerd_installation.sh | |
| docker | docker_installation.sh | The docker engine is no longer to be supported in Kubernetes 1.23+, and it is required cri-docker. |
| cri-docker | cri-dockerd_installation.sh | a middleware between k8s and docker. |

In addtion, some of the CRI scripts are required the configuration setup, the configuration files are available at 
~/k8s-infra-setup.ubuntu/etc

the mapping of CRIs and their configuration files:

| Name | Script | Configuration |
| --- | --- | --- |
| cri-o | crio_installation.sh | cri-o_settings.sh |
| containerd | containerd_installation.sh | containerd_settings.sh |
| docker | docker_installation.sh | N/A |
| cri-docker | cri-dockerd_installation.sh | cri-dockerd_settings.sh |

## Kubernetes package installation

The script to install the Kubernetes package is with:

```bash
./k8s_installation.sh
```

and, its configuration file is at:

~/k8s-infra-setup/etc/k8s_settings.sh

for the the most important information duration the setup:

1. the Kubernetes package version should be downloaded at local, and the version is to be installed for the runtime.
2. network topology for the pod and the service.
  
## References

- [Container Runtime](https://kubernetes.io/docs/setup/production-environment/container-runtimes/)
- [cri-o installation](https://github.com/cri-o/packaging/blob/main/README.md#usage)
- [cri-docker installation](https://mirantis.github.io/cri-dockerd/usage/install-manually/)
- [containerd installation](https://github.com/containerd/containerd/blob/main/docs/getting-started.md)
