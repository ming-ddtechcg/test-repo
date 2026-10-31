package serviceaccount

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

type ServiceAccount struct {
	Clientset *kubernetes.Clientset
}

func (serviceAccount *ServiceAccount) accessServiceAccount(sa *corev1.ServiceAccount) {
	if sa == nil {
		return
	}

	fmt.Fprintf(os.Stdout, "name: %v\n", sa.Name)
	fmt.Fprintf(os.Stdout, "namespace: %v\n", sa.Namespace)

	if len(sa.Labels) > 0 {
		fmt.Fprintf(os.Stdout, "labels:\n")
		for key, value := range sa.Labels {
			fmt.Fprintf(os.Stdout, "\tkey: %v, value: %v\n", key, value)
		}
	}

	if len(sa.Annotations) > 0 {
		fmt.Fprintf(os.Stdout, "annontations:\n")
		for key, value := range sa.Annotations {
			fmt.Fprintf(os.Stdout, "\tkey: %v, value: %v\n", key, value)
		}
	}
}

func (serviceAccount *ServiceAccount) retrieveAllServiceAccountItem(namespace *string, listOptions *metav1.ListOptions) (*corev1.ServiceAccountList, error) {

	list, err := serviceAccount.Clientset.CoreV1().ServiceAccounts(*namespace).List(context.Background(), *listOptions)
	if err != nil {
		return nil, err
	}

	return list, nil
}

func (serviceAccount *ServiceAccount) retrieveAllServiceAccounts(namespace *string, listOptions *metav1.ListOptions) ([]corev1.ServiceAccount, error) {

	list, err := serviceAccount.retrieveAllServiceAccountItem(namespace, listOptions)
	if err != nil {
		return nil, err
	}

	return list.Items, nil
}

func (serviceAccount *ServiceAccount) retrieveServiceAccountWithSpecificAnnonations(annontations, namespace string) ([]corev1.ServiceAccount, error) {

	// annonation is no option in metav1.ListOptions{}
	listOptions := &metav1.ListOptions{}

	list, err := serviceAccount.retrieveAllServiceAccounts(&namespace, listOptions)

	if err != nil {
		return nil, err
	}

	annonationElements := strings.Split(annontations, ",")

	var saList []corev1.ServiceAccount
	for _, sa := range list {
		matchCount := 0

		for _, eachAnnonation := range annonationElements {
			eachAnnonations := strings.Split(eachAnnonation, "=")
			if sa.Annotations[strings.TrimSpace(eachAnnonations[0])] == strings.TrimSpace(eachAnnonations[1]) {
				matchCount++
			}
		}

		if len(annonationElements) == matchCount {
			saList = append(saList, sa)
		}
	}

	return saList, nil
}

func (serviceAccount *ServiceAccount) retrieveServiceAccountWithSpecificLabels(labels, namespace string) ([]corev1.ServiceAccount, error) {

	list, err := serviceAccount.Clientset.CoreV1().ServiceAccounts(namespace).List(
		context.Background(),
		metav1.ListOptions{
			LabelSelector: labels,
		})
	if err != nil {
		return nil, err
	}

	return list.Items, nil
}

func (serviceAccount *ServiceAccount) retrieveServiceAccountByName(serviceAccountName, namespace string) (*corev1.ServiceAccount, error) {

	sa, err := serviceAccount.Clientset.CoreV1().ServiceAccounts(namespace).Get(context.Background(), serviceAccountName, metav1.GetOptions{})
	if err != nil {
		return nil, err
	}

	return sa, nil
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
				"myapp.example.com/managed": "true",
				"myapp.example.com/owner":   "platform-team",
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

func (serviceAccount *ServiceAccount) createATestServiceAccountWithToken(call bool, serviceAccountName, secretTokenName, namespace string) {
	if !call {
		return
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

	_, err := serviceAccount.Clientset.CoreV1().ServiceAccounts(namespace).Create(context.Background(), sa, metav1.CreateOptions{})
	if err != nil {
		fmt.Fprintf(os.Stderr, "error creating serviceaccount: %v\n", err)
		return
	} else {
		fmt.Fprintf(os.Stderr, "a serviceaccount (%v) is created\n", serviceAccountName)
	}

	secret := &corev1.Secret{
		ObjectMeta: metav1.ObjectMeta{
			Name:      secretTokenName,
			Namespace: namespace,
			Labels:    map[string]string{"app.kubernetes.io/name": "myapp"},
			Annotations: map[string]string{
				corev1.ServiceAccountNameKey: "myapp", // "kubernetes.io/service-account.name"
			},
		},
		Type: corev1.SecretTypeServiceAccountToken, // "kubernetes.io/service-account-token"
	}
	_, err = serviceAccount.Clientset.CoreV1().Secrets(namespace).Create(context.Background(), secret, metav1.CreateOptions{})
	if err != nil {
		fmt.Fprintf(os.Stderr, "error creating secret token: %v\n", err)
		return
	} else {
		fmt.Fprintf(os.Stderr, "a secret token (%v) is created\n", secretTokenName)
	}
}

func (serviceAccount *ServiceAccount) deleteATestServiceAccountSecret(call bool, secretName, namespace string) {
	if !call {
		return
	}

	err := serviceAccount.Clientset.CoreV1().Secrets(namespace).Delete(context.Background(), secretName, metav1.DeleteOptions{})
	if err != nil {
		fmt.Fprintf(os.Stderr, "error deleting secret: %v\n", err)
		return
	} else {
		fmt.Fprintf(os.Stderr, "a secret (%v) is deleted\n", secretName)
	}
}

func (serviceAccount *ServiceAccount) getServiceAccountWithSpecificAnnonations(call bool, annontations, namespace string) {
	if !call {
		return
	}

	saList, err := serviceAccount.retrieveServiceAccountWithSpecificAnnonations(annontations, namespace)

	if err != nil {
		fmt.Fprintf(os.Stderr, "error fetching configmap: %v\n", err)
		return
	} else {
		fmt.Fprintf(os.Stderr, "fetched a list of serviceaccount\n")
	}

	for _, sa := range saList {
		serviceAccount.accessServiceAccount(&sa)
	}
}

func (serviceAccount *ServiceAccount) getServiceAccountWithSpecificLabels(call bool, labels, namespace string) {
	if !call {
		return
	}

	saList, err := serviceAccount.retrieveServiceAccountWithSpecificLabels(labels, namespace)

	if err != nil {
		fmt.Fprintf(os.Stderr, "error fetching serviceaccount: %v\n", err)
		return
	} else {
		fmt.Fprintf(os.Stderr, "fetched a list of serviceaccount\n")
	}

	for _, sa := range saList {
		serviceAccount.accessServiceAccount(&sa)
	}
}

func (serviceAccount *ServiceAccount) printAServiceAccountIntoJson(call bool, serviceAccountName, namespace string) {
	if !call {
		return
	}

	sa, err := serviceAccount.retrieveServiceAccountByName(serviceAccountName, namespace)
	if err != nil {
		fmt.Fprintf(os.Stderr, "error fetching serviceaccount: %v\n", err)
		return
	}

	out, err := json.MarshalIndent(sa, "", "  ")
	if err != nil {
		fmt.Fprintf(os.Stderr, "error to convert a serviceaccount into json: %v\n", err)
	}

	fmt.Println(string(out))
}

func (serviceAccount *ServiceAccount) printListServiceAccountIntoJson(call, withItem bool, namespace string) {
	if !call {
		return
	}

	var err error
	var list any

	if withItem {
		list, err = serviceAccount.retrieveAllServiceAccountItem(&namespace, &metav1.ListOptions{})
	} else {
		list, err = serviceAccount.retrieveAllServiceAccounts(&namespace, &metav1.ListOptions{})
	}

	if err != nil {
		fmt.Fprintf(os.Stderr, "error fetching configmap list: %v\n", err)
		return
	}

	out, err := json.MarshalIndent(list, "", "  ")
	if err != nil {
		fmt.Fprintf(os.Stderr, "error to convert list configmap into json: %v\n", err)
	}

	fmt.Println(string(out))
}

func (serviceAccount *ServiceAccount) printAServiceAccountIntoYaml(call bool, serviceAccountName, namespace string) {
	if !call {
		return
	}

	sa, err := serviceAccount.retrieveServiceAccountByName(serviceAccountName, namespace)
	if err != nil {
		fmt.Fprintf(os.Stderr, "error fetching serviceaccount: %v\n", err)
		return
	}

	out, err := yaml.Marshal(sa)
	if err != nil {
		fmt.Fprintf(os.Stderr, "error to convert a serviceaccount into yaml: %v\n", err)
	}

	fmt.Println(string(out))
}

func (serviceAccount *ServiceAccount) Workon(call bool) {
	if !call {
		return
	}

	fmt.Fprintf(os.Stderr, "\n")
	fmt.Fprintf(os.Stderr, "serviceaccount section\n")
	fmt.Fprintf(os.Stderr, "-----------------------------\n")

	serviceAccount.createATestServiceAccount(false, "test", "dev")

	serviceAccount.createATestServiceAccountWithToken(false, "test", "test-token", "dev")

	serviceAccount.getServiceAccountWithSpecificAnnonations(false, "myapp.example.com/managed=true,myapp.example.com/owner=platform-team", "")

	serviceAccount.getServiceAccountWithSpecificLabels(false, "app.kubernetes.io/name=myapp", "")

	serviceAccount.printAServiceAccountIntoJson(false, "test", "dev")

	serviceAccount.printListServiceAccountIntoJson(false, true, "dev")

	serviceAccount.printAServiceAccountIntoYaml(false, "test", "dev")

	serviceAccount.deleteATestServiceAccountSecret(false, "test-token", "dev")

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
