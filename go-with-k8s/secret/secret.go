package secret

import (
	"context"
	"fmt"
	"os"

	corev1 "k8s.io/api/core/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes"
)

type Secret struct {
	Clientset *kubernetes.Clientset
}

func (secret *Secret) accessSecret(sc *corev1.Secret) {
	if sc == nil {
		return
	}

	fmt.Fprintf(os.Stdout, "secret\n")
	fmt.Fprintf(os.Stdout, "name: %v\n", sc.Name)
	fmt.Fprintf(os.Stdout, "namespace: %v\n", sc.Namespace)
}

func (secret *Secret) retrieveAllSecrets(namespace *string, listOptions *metav1.ListOptions) ([]corev1.Secret, error) {

	list, err := secret.Clientset.CoreV1().Secrets(*namespace).List(context.Background(), *listOptions)
	if err != nil {
		return nil, err
	}

	return list.Items, nil
}

// ---

func (secret *Secret) listAllSecrets(call bool) {
	if !call {
		return
	}

	namespace := metav1.NamespaceAll
	listOptions := &metav1.ListOptions{}

	list, err := secret.retrieveAllSecrets(&namespace, listOptions)
	if err != nil {
		fmt.Fprintf(os.Stderr, "error fetching secret: %v\n", err)
		return
	} else {
		fmt.Fprintf(os.Stderr, "fetched a list of secret\n")
	}

	for _, sc := range list {
		secret.accessSecret(&sc)
	}
}

func (secret *Secret) createATestSecret(call bool, secretName, namespace string) {
	if !call {
		return
	}

	sc := &corev1.Secret{
		ObjectMeta: metav1.ObjectMeta{
			Name:      secretName,
			Namespace: namespace,
			Labels: map[string]string{
				"app.kubernetes.io/name": "myapp",
			},
		},
		Type: corev1.SecretTypeOpaque,
		StringData: map[string]string{
			"DB_USER":     "admin",
			"DB_PASSWORD": "s3cr3t",
		},
	}

	_, err := secret.Clientset.CoreV1().Secrets(namespace).Create(context.Background(), sc, metav1.CreateOptions{})
	if err != nil {
		fmt.Fprintf(os.Stderr, "error creating secret: %v\n", err)
		return
	} else {
		fmt.Fprintf(os.Stderr, "a secret (%v) is created\n", secretName)
	}
}

func (secret *Secret) deleteATestSecret(call bool, secretName, namespace string) {
	if !call {
		return
	}

	err := secret.Clientset.CoreV1().Secrets(namespace).Delete(context.Background(), secretName, metav1.DeleteOptions{})
	if err != nil {
		fmt.Fprintf(os.Stderr, "error deleting secret: %v\n", err)
		return
	} else {
		fmt.Fprintf(os.Stderr, "a secret (%v) is deleted\n", secretName)
	}
}

func (secret *Secret) Workon(call bool) {
	if !call {
		return
	}

	fmt.Fprintf(os.Stderr, "\n")
	fmt.Fprintf(os.Stderr, "secret section\n")
	fmt.Fprintf(os.Stderr, "-----------------------------\n")

	secret.createATestSecret(false, "test", "dev")

	secret.listAllSecrets(false)

	secret.deleteATestSecret(false, "test", "dev")

	fmt.Fprintf(os.Stderr, "-----------------------------\n")
}
