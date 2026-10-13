# HAProxy infra node
Using HAProxy as a gateway to route the on-prem traffic.

While configing the K8s control planes with the specific endpoint in:

1. Virtual IP (VIP)
2. a DNS domain name

therefore, all communications to the api-servers will go by VIP or the DNS.

For the worker node traffic to serve with Ingress, HAProxy can route the ingress for the load balance purpose.

The following is the HAProxy configuration for the 3 api-servers and 2 worker nodes with ingress:

```console
global
	log /dev/log	local0
	log /dev/log	local1 notice
	chroot /var/lib/haproxy
	stats socket /run/haproxy/admin.sock mode 660 level admin expose-fd listeners
	stats timeout 30s
	user haproxy
	group haproxy
	daemon

defaults
	log	global
	mode	http
	option	httplog
	option	dontlognull
        timeout connect 5000
        timeout client  50000
        timeout server  50000
	errorfile 400 /etc/haproxy/errors/400.http
	errorfile 403 /etc/haproxy/errors/403.http
	errorfile 408 /etc/haproxy/errors/408.http
	errorfile 500 /etc/haproxy/errors/500.http
	errorfile 502 /etc/haproxy/errors/502.http
	errorfile 503 /etc/haproxy/errors/503.http
	errorfile 504 /etc/haproxy/errors/504.http

# ---------------------------------------------------------------------
# HTTP Forwarding (Port 6443)
# ---------------------------------------------------------------------
frontend k8s-api
	bind *:6443
	mode tcp
	option tcplog
	default_backend k8s-api

backend k8s-api
	mode tcp
	option tcplog
	option tcp-check
	balance roundrobin
	server k8s-master-01 192.168.131.20:6443 check
	server k8s-master-02 192.168.131.21:6443 check
	server k8s-master-03 192.168.131.22:6443 check

# ---------------------------------------------------------------------
# HTTP Forwarding (Port 80)
# ---------------------------------------------------------------------
frontend k8s-http-front
	bind *:80
	mode tcp
	option tcplog
	default_backend k8s-http-back

backend k8s-http-back
	mode tcp
	option tcplog
	option tcp-check
	balance roundrobin
	server k8s-worker-http-01 192.168.131.23:80 check
	server k8s-worker-http-02 192.168.131.24:80 check

# ---------------------------------------------------------------------
# HTTPS Forwarding (Port 443)
# ---------------------------------------------------------------------
frontend k8s-https-front
	bind *:443
	mode tcp
	option tcplog
	default_backend k8s-https-back

backend k8s-https-back
	mode tcp
	option tcplog
	option tcp-check
	balance roundrobin
	server k8s-worker-http-01 192.168.131.23:443 check
	server k8s-worker-http-02 192.168.131.24:443 check
```

For testing the ingress, a demo deployment is available at:

[test-webservice](https://github.com/ming-ddtechcg/k8s-utils/tree/main/k8s-tests/ingress-nginx-tester)


## Notes

1. HAProxy api-server setup also works for the single control plane/master node model.
2. HAProxy routing for the worker loads may apply the static route with the layer 4 cookie setup, an example likes:
   ```console
	backend k8s-http-back
        	mode http
        	balance roundrobin
                cookie SERVERID insert indirect nocache
        	server k8s-worker-http-01 192.168.131.23:80 check cookie k8s-worker-web-1
        	server k8s-worker-http-02 192.168.131.24:80 check cookie k8s-worker-web-2
   ```
