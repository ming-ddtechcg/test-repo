package deployment

import (
	"context"
	"fmt"
	"os"

	appsv1 "k8s.io/api/apps/v1"
	corev1 "k8s.io/api/core/v1"
	"k8s.io/apimachinery/pkg/api/resource"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes"
	"k8s.io/utils/ptr"
)

type Deployment struct {
	Clientset *kubernetes.Clientset
}

// ---

func (deployment *Deployment) createATestServiceAccount(call bool, serviceAccountName, namespace string) error {
	if !call {
		return nil
	}

	sa := &corev1.ServiceAccount{
		ObjectMeta: metav1.ObjectMeta{
			Name:      serviceAccountName,
			Namespace: namespace,
			Labels:    map[string]string{"app.kubernetes.io/name": "myapp"},
			Annotations: map[string]string{
				"myapp.example.com/managed": "true",
				"myapp.example.com/owner":   "platform-team",
			},
		},
	}

	_, err := deployment.Clientset.CoreV1().ServiceAccounts(namespace).Create(context.Background(), sa, metav1.CreateOptions{})
	if err != nil {
		return err
	}

	return nil
}

func (deployment *Deployment) createATestDeployment(call bool, deploymentName, namespace string) {
	if !call {
		return
	}

	err := deployment.createATestServiceAccount(call, deploymentName, namespace)
	if err != nil {
		fmt.Fprintf(os.Stderr, "error creating serviceaccount: %v\n", err)
	} else {
		fmt.Fprintf(os.Stderr, "a serviceaccount (%v) is created\n", deploymentName)
	}

	labels := map[string]string{"app.kubernetes.io/name": "myapp"}

	deploy := &appsv1.Deployment{
		ObjectMeta: metav1.ObjectMeta{
			Name:      deploymentName,
			Namespace: namespace,
			Labels:    labels,
		},
		Spec: appsv1.DeploymentSpec{
			Replicas: ptr.To(int32(1)),
			Selector: &metav1.LabelSelector{MatchLabels: labels},
			Template: corev1.PodTemplateSpec{
				ObjectMeta: metav1.ObjectMeta{Labels: labels},
				Spec: corev1.PodSpec{
					ServiceAccountName: deploymentName,
					Containers: []corev1.Container{
						{
							Name:            deploymentName,
							Image:           "harbor.ddtechcg.com:5001/playground/myapp:test",
							ImagePullPolicy: corev1.PullAlways,
							Command: []string{
								"sh",
								"-c",
								"sleep 1d",
							},
							Resources: corev1.ResourceRequirements{
								Requests: corev1.ResourceList{
									corev1.ResourceCPU:    resource.MustParse("250m"),
									corev1.ResourceMemory: resource.MustParse("64Mi"),
								},
								Limits: corev1.ResourceList{
									corev1.ResourceCPU:    resource.MustParse("350m"),
									corev1.ResourceMemory: resource.MustParse("256Mi"),
								},
							},
						},
					},
				},
			},
		},
	}

	_, err = deployment.Clientset.AppsV1().Deployments(namespace).Create(context.Background(), deploy, metav1.CreateOptions{})
	if err != nil {
		fmt.Fprintf(os.Stderr, "error creating deployment: %v\n", err)
		return
	} else {
		fmt.Fprintf(os.Stderr, "a deployment (%v) is created\n", deploymentName)
	}
}

func (deployment *Deployment) deleteATestServiceAccount(call bool, deploymentName, namespace string) {
	if !call {
		return
	}

	err := deployment.Clientset.CoreV1().ServiceAccounts(namespace).Delete(context.Background(), deploymentName, metav1.DeleteOptions{})
	if err != nil {
		fmt.Fprintf(os.Stderr, "error deleting serviceaccount: %v\n", err)
		return
	} else {
		fmt.Fprintf(os.Stderr, "a serviceaccount (%v) is deleted\n", deploymentName)
	}
}

func (deployment *Deployment) deleteATestDeployment(call bool, deploymentName, namespace string) {
	if !call {
		return
	}

	deployment.deleteATestServiceAccount(call, deploymentName, namespace)

	err := deployment.Clientset.AppsV1().Deployments(namespace).Delete(context.Background(), deploymentName, metav1.DeleteOptions{})
	if err != nil {
		fmt.Fprintf(os.Stderr, "error deleting deployment: %v\n", err)
		return
	} else {
		fmt.Fprintf(os.Stderr, "a deployment (%v) is deleted\n", deploymentName)
	}
}

func (deployment *Deployment) Workon(call bool) {
	if !call {
		return
	}

	fmt.Fprintf(os.Stderr, "\n")
	fmt.Fprintf(os.Stderr, "deployment section\n")
	fmt.Fprintf(os.Stderr, "-----------------------------\n")

	deployment.deleteATestDeployment(true, "test", "dev")
	deployment.createATestDeployment(true, "test", "dev")

	// configMap.listAllConfigMap(false)

	// configMap.getConfigMapByName(false, "test", "dev")

	// configMap.getConfigMapWithSpecificAnnonations(false, "meta.helm.sh/release-name=tempo,meta.helm.sh/release-namespace=opentelemetry", "")

	// configMap.getConfigMapWithSpecificLabels(false, "app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=loki", "")

	// configMap.updateConfigMapByName(true, "test", "dev")

	// configMap.printAConfigMapIntoJson(false, "test", "dev")

	// configMap.printListConfigMapIntoJson(false, false, "dev")

	// configMap.printAConfigMapIntoYaml(false, "test", "dev")

	deployment.deleteATestDeployment(false, "test", "dev")

	fmt.Fprintf(os.Stderr, "-----------------------------\n")
}
