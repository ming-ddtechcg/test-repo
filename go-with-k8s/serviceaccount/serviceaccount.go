package serviceaccount

import (
	"context"
	"fmt"
	"os"

	corev1 "k8s.io/api/core/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes"
)

type ServiceAccount struct {
	Clientset *kubernetes.Clientset
}

// ---

func (serviceAccount *ServiceAccount) createATestServiceAccount(call bool, serviceAccountName, namespace string) {
	if !call {
		return
	}

	sa := &corev1.ServiceAccount{
		ObjectMeta: metav1.ObjectMeta{
			Name:      serviceAccountName,
			Namespace: namespace,
			Labels:    map[string]string{"app.kubernetes.io/name": "myapp"},
			Annotations: map[string]string{
				"myapp.example.com/managed":          "true",
				"myapp.example.com/owner":            "platform-team",
				"kubernetes.io/service-account.name": "true",
			},
		},
	}

	_, err := serviceAccount.Clientset.CoreV1().ServiceAccounts(namespace).Create(context.Background(), sa, metav1.CreateOptions{})
	if err != nil {
		fmt.Fprintf(os.Stderr, "error creating serviceaccount: %v\n", err)
	} else {
		fmt.Fprintf(os.Stderr, "a serviceaccount (%v) is created\n", serviceAccountName)
	}
}

func (serviceAccount *ServiceAccount) deleteATestServiceAccount(call bool, serviceAccountName, namespace string) {
	if !call {
		return
	}

	err := serviceAccount.Clientset.CoreV1().ServiceAccounts(namespace).Delete(context.Background(), serviceAccountName, metav1.DeleteOptions{})
	if err != nil {
		fmt.Fprintf(os.Stderr, "error deleting serviceaccount: %v\n", err)
		return
	} else {
		fmt.Fprintf(os.Stderr, "a serviceaccount (%v) is deleted\n", serviceAccountName)
	}
}

func (serviceAccount *ServiceAccount) Workon(call bool) {
	if !call {
		return
	}

	fmt.Fprintf(os.Stderr, "\n")
	fmt.Fprintf(os.Stderr, "serviceaccount section\n")
	fmt.Fprintf(os.Stderr, "-----------------------------\n")

	serviceAccount.createATestServiceAccount(true, "test", "dev")

	serviceAccount.deleteATestServiceAccount(false, "test", "dev")

	fmt.Fprintf(os.Stderr, "-----------------------------\n")
}

/*
// 1.
// Short-lived token (recommended)
kubectl create token myapp -n dev --duration=24h

import authv1 "k8s.io/api/authentication/v1"

// 2.
// This uses the TokenRequest API and prints a JWT that expires after the requested duration.
// The API server may cap the maximum duration, so very long requests can come back shorter.
// It isn’t stored anywhere in the cluster, so create a new one when it expires.

expiry := int64(24 * 60 * 60)
tr, err := clientset.CoreV1().ServiceAccounts("dev").CreateToken(ctx, "myapp",
	&authv1.TokenRequest{
		Spec: authv1.TokenRequestSpec{ExpirationSeconds: &expiry},
	},
	metav1.CreateOptions{},
)
if err != nil {
	return err
}
token := tr.Status.Token

// Long-lived token Secret (when a non-expiring token is unavoidable)
apiVersion: v1
kind: Secret
metadata:
  name: myapp-token
  namespace: dev
  annotations:
    kubernetes.io/service-account.name: myapp
type: kubernetes.io/service-account-token


*/
