# Setup the first master node with SANs

The following is an example for setting up a first master node with SANs (Subject Alternative Names) for the ingress and apiserver:

```
$ ./cluster_setup.sh
[sudo] password for <user>:

Is this the first master node (y/n): y

Enter extra subjcet alernative name(s) for certifcats to access the api-server
(press enter to ignore, use comma between each SAN)
: apiserver.<FQDN>

```
