package main

import (
	"fmt"
	"os"

	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/rest"
	"k8s.io/client-go/tools/clientcmd"

	"example.com/myapp/configmap"
	"example.com/myapp/secret"
	"example.com/myapp/serviceaccount"
)

func buildConfig() (*rest.Config, error) {
	if kubeconfig := os.Getenv("KUBECONFIG"); kubeconfig != "" {
		return clientcmd.BuildConfigFromFlags("", kubeconfig)
	}
	return rest.InClusterConfig()
}

func main() {

	config, err := buildConfig()
	if err != nil {
		fmt.Fprintf(os.Stderr, "error building kubernetes config: %v\n", err)
		os.Exit(1)
	} else {
		fmt.Fprintf(os.Stderr, "kubernetes config is good to go\n")
	}

	clientset, err := kubernetes.NewForConfig(config)
	if err != nil {
		fmt.Fprintf(os.Stderr, "error creating kubernetes client: %v\n", err)
		os.Exit(2)
	} else {
		fmt.Fprintf(os.Stderr, "kubernetes client is created\n")
	}

	// configmap section
	configmap := &configmap.ConfigMap{
		Clientset: clientset,
	}
	configmap.Workon(false)

	// secret section
	secret := &secret.Secret{
		Clientset: clientset,
	}
	secret.Workon(false)

	// serviceaccount section
	serviceaccount := &serviceaccount.ServiceAccount{
		Clientset: clientset,
	}
	serviceaccount.Workon(false)
}
