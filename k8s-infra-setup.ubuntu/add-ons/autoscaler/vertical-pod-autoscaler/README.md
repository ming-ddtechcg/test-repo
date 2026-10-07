# vertical-pod-autoscaler

# COMING SOON...

## Clone the autoscaler repository

```
git clone https://github.com/kubernetes/autoscaler.git
```

## Navigate to the VPA directory

```
cd autoscaler/vertical-pod-autoscaler/
```

## Deploy the VPA CRDs and components

```bash
./hack/vpa-up.sh
```

## Example

```yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: my-app-vpa
  namespace: default
spec:
  # Target the deployment you want to scale
  targetRef:
    apiVersion: "apps/v1"
    kind: Deployment
    name: my-app-deployment
  updatePolicy:
    # Controls how resource updates are applied
    updateMode: "Auto" 
  resourcePolicy:
    containerPolicies:
      - containerName: '*'
        minAllowed:
          cpu: "100m"
          memory: "100Mi"
        maxAllowed:
          cpu: "2"
          memory: "2Gi"
```

## Tear down

```bash
./hack/vpa-down.sh
```

## Rerferences

- [Vertical Pod Autoscaler](https://github.com/kubernetes/autoscaler/tree/master/vertical-pod-autoscaler)
- [Vertical Pod Autoscaling](https://kubernetes.io/docs/concepts/workloads/autoscaling/vertical-pod-autoscale/)
