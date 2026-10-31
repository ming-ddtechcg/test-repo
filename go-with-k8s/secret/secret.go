package secret

import (
	"context"
	"encoding/json"
	"fmt"
	"os"
	"strings"

	"go.yaml.in/yaml/v2"
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

	fmt.Fprintf(os.Stdout, "\n")
	fmt.Fprintf(os.Stdout, "name: %v\n", sc.Name)
	fmt.Fprintf(os.Stdout, "namespace: %v\n", sc.Namespace)
	fmt.Fprintf(os.Stdout, "type: %v\n", sc.Type)

	if len(sc.Labels) > 0 {
		fmt.Fprintf(os.Stdout, "labels:\n")
		for key, value := range sc.Labels {
			fmt.Fprintf(os.Stdout, "\tkey: %v, value: %v\n", key, value)
		}
	}

	if len(sc.Annotations) > 0 {
		fmt.Fprintf(os.Stdout, "annontations:\n")
		for key, value := range sc.Annotations {
			fmt.Fprintf(os.Stdout, "\tkey: %v, value: %v\n", key, value)
		}
	}

	if len(sc.Data) > 0 {
		fmt.Fprintf(os.Stdout, "data:\n")
		for key, value := range sc.Data {
			fmt.Fprintf(os.Stdout, "\tkey: %v, value: %v\n", key, string(value))
		}
	}
}

func (secret *Secret) retrieveAllSecretItem(namespace *string, listOptions *metav1.ListOptions) (*corev1.SecretList, error) {

	list, err := secret.Clientset.CoreV1().Secrets(*namespace).List(context.Background(), *listOptions)
	if err != nil {
		return nil, err
	}

	return list, nil
}

func (secret *Secret) retrieveAllSecrets(namespace *string, listOptions *metav1.ListOptions) ([]corev1.Secret, error) {

	list, err := secret.retrieveAllSecretItem(namespace, listOptions)
	if err != nil {
		return nil, err
	}

	return list.Items, nil
}

func (secret *Secret) retrieveSecretByName(secretName, namespace string) (*corev1.Secret, error) {

	cm, err := secret.Clientset.CoreV1().Secrets(namespace).Get(context.Background(), secretName, metav1.GetOptions{})
	if err != nil {
		return nil, err
	}

	return cm, nil
}

func (secret *Secret) retrieveSecretWithSpecificAnnonations(annontations, namespace string) ([]corev1.Secret, error) {

	// annonation is no option in metav1.ListOptions{}
	listOptions := &metav1.ListOptions{}

	list, err := secret.retrieveAllSecrets(&namespace, listOptions)

	if err != nil {
		return nil, err
	}

	annonationElements := strings.Split(annontations, ",")

	var scList []corev1.Secret
	for _, sc := range list {
		matchCount := 0

		for _, eachAnnonation := range annonationElements {
			eachAnnonations := strings.Split(eachAnnonation, "=")
			if sc.Annotations[strings.TrimSpace(eachAnnonations[0])] == strings.TrimSpace(eachAnnonations[1]) {
				matchCount++
			}
		}

		if len(annonationElements) == matchCount {
			scList = append(scList, sc)
		}
	}

	return scList, nil
}

func (secret *Secret) retrieveSecretWithSpecificLabels(labels, namespace string) ([]corev1.Secret, error) {

	list, err := secret.Clientset.CoreV1().Secrets(namespace).List(
		context.Background(),
		metav1.ListOptions{
			LabelSelector: labels,
		})
	if err != nil {
		return nil, err
	}

	return list.Items, nil
}

func (secret *Secret) updateSecretWithConfigMap(namespace string, sc *corev1.Secret) error {

	_, err := secret.Clientset.CoreV1().Secrets(namespace).Update(context.Background(), sc, metav1.UpdateOptions{})

	return err
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
			Annotations: map[string]string{
				"myapp.example.com/managed": "true",
				"myapp.example.com/owner":   "platform-team",
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

func (secret *Secret) getSecretByName(call bool, secretName, namespace string) {
	if !call {
		return
	}

	sc, err := secret.retrieveSecretByName(secretName, namespace)
	if err != nil {
		fmt.Fprintf(os.Stderr, "error fetching secret: %v\n", err)
		return
	}

	secret.accessSecret(sc)
}

func (secret *Secret) getSecretWithSpecificAnnonations(call bool, annontations, namespace string) {
	if !call {
		return
	}

	scList, err := secret.retrieveSecretWithSpecificAnnonations(annontations, namespace)

	if err != nil {
		fmt.Fprintf(os.Stderr, "error fetching secret: %v\n", err)
		return
	} else {
		fmt.Fprintf(os.Stderr, "fetched a list of secret\n")
	}

	for _, sc := range scList {
		secret.accessSecret(&sc)
	}
}

func (secret *Secret) getSecretWithSpecificLabels(call bool, labels, namespace string) {
	if !call {
		return
	}

	scList, err := secret.retrieveSecretWithSpecificLabels(labels, namespace)

	if err != nil {
		fmt.Fprintf(os.Stderr, "error fetching secret: %v\n", err)
		return
	} else {
		fmt.Fprintf(os.Stderr, "fetched a list of secret\n")
	}

	for _, cm := range scList {
		secret.accessSecret(&cm)
	}
}

func (secret *Secret) updateSecretByName(call bool, secretName, namespace string) {
	if !call {
		return
	}

	sc, err := secret.retrieveSecretByName(secretName, namespace)
	if err != nil {
		fmt.Fprintf(os.Stderr, "error fetching configmap: %v\n", err)
		return
	}

	sc.Data["DB_PASSWORD"] = []byte("1234") // change or add a key
	// delete(sc.Data, "OLD_SETTING")		// remove a key

	err = secret.updateSecretWithConfigMap(namespace, sc)
	if err != nil {
		fmt.Fprintf(os.Stderr, "error updating secret: %v\n", err)
	}

	secret.getSecretByName(true, sc.Name, sc.Namespace)
}

func (secret *Secret) printASecretIntoJson(call bool, secretName, namespace string) {
	if !call {
		return
	}

	sc, err := secret.retrieveSecretByName(secretName, namespace)
	if err != nil {
		fmt.Fprintf(os.Stderr, "error fetching secret: %v\n", err)
		return
	}

	out, err := json.MarshalIndent(sc, "", "  ")
	if err != nil {
		fmt.Fprintf(os.Stderr, "error to convert a secret into json: %v\n", err)
	}

	fmt.Println(string(out))
}

func (secret *Secret) printListSecretIntoJson(call, withItem bool, namespace string) {
	if !call {
		return
	}

	var err error
	var list any

	if withItem {
		list, err = secret.retrieveAllSecretItem(&namespace, &metav1.ListOptions{})
	} else {
		list, err = secret.retrieveAllSecrets(&namespace, &metav1.ListOptions{})
	}

	if err != nil {
		fmt.Fprintf(os.Stderr, "error fetching secret list: %v\n", err)
		return
	}

	out, err := json.MarshalIndent(list, "", "  ")
	if err != nil {
		fmt.Fprintf(os.Stderr, "error to convert list secret into json: %v\n", err)
	}

	fmt.Println(string(out))
}

func (secret *Secret) printASecretIntoYaml(call bool, secretName, namespace string) {
	if !call {
		return
	}

	sc, err := secret.retrieveSecretByName(secretName, namespace)
	if err != nil {
		fmt.Fprintf(os.Stderr, "error fetching secret: %v\n", err)
		return
	}

	out, err := yaml.Marshal(sc)
	if err != nil {
		fmt.Fprintf(os.Stderr, "error to convert a secret into yaml: %v\n", err)
	}

	fmt.Println(string(out))
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

	secret.getSecretByName(false, "test", "dev")

	secret.getSecretWithSpecificAnnonations(false, "myapp.example.com/managed=true,myapp.example.com/owner=platform-team", "")

	secret.getSecretWithSpecificLabels(false, "app.kubernetes.io/name=myapp", "")

	secret.updateSecretByName(false, "test", "dev")

	secret.printASecretIntoJson(false, "test", "dev")

	secret.printListSecretIntoJson(false, false, "dev")

	secret.printASecretIntoYaml(false, "test", "dev")

	secret.deleteATestSecret(true, "test", "dev")

	fmt.Fprintf(os.Stderr, "-----------------------------\n")
}
