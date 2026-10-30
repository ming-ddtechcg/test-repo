package secret

import (
	"fmt"

	"k8s.io/client-go/kubernetes"
)

type Secret struct {
	Clientset *kubernetes.Clientset
}

func (secret *Secret) Workon() {

	fmt.Println("")
	fmt.Println("-----------------------------\n")

	//configMap.listAllConfigMap(true)
	//configMap.getSpecificConfigMap(false, "", "")

	fmt.Println("-----------------------------\n")
}
