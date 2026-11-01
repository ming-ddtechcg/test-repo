package configmap

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

type ConfigMap struct {
	Clientset *kubernetes.Clientset
}

func (configMap *ConfigMap) accessConfigMap(cm *corev1.ConfigMap) {
	if cm == nil {
		return
	}

	fmt.Fprintf(os.Stdout, "name: %v\n", cm.Name)
	fmt.Fprintf(os.Stdout, "namespace: %v\n", cm.Namespace)

	if len(cm.Labels) > 0 {
		fmt.Fprintf(os.Stdout, "labels:\n")
		for key, value := range cm.Labels {
			fmt.Fprintf(os.Stdout, "\tkey: %v, value: %v\n", key, value)
		}
	}

	if len(cm.Annotations) > 0 {
		fmt.Fprintf(os.Stdout, "annontations:\n")
		for key, value := range cm.Annotations {
			fmt.Fprintf(os.Stdout, "\tkey: %v, value: %v\n", key, value)
		}
	}

	if len(cm.Data) > 0 {
		fmt.Fprintf(os.Stdout, "data:\n")
		for key, value := range cm.Data {
			fmt.Fprintf(os.Stdout, "\tkey: %v, value: %v\n", key, value)
		}
	}
}

func (configMap *ConfigMap) retrieveAllConfigMapItem(namespace *string, listOptions *metav1.ListOptions) (*corev1.ConfigMapList, error) {

	list, err := configMap.Clientset.CoreV1().ConfigMaps(*namespace).List(context.Background(), *listOptions)
	if err != nil {
		return nil, err
	}

	return list, nil
}

func (configMap *ConfigMap) retrieveAllConfigMaps(namespace *string, listOptions *metav1.ListOptions) ([]corev1.ConfigMap, error) {

	list, err := configMap.retrieveAllConfigMapItem(namespace, listOptions)
	if err != nil {
		return nil, err
	}

	return list.Items, nil
}

func (configMap *ConfigMap) retrieveConfigMapWithSpecificAnnonations(annontations, namespace string) ([]corev1.ConfigMap, error) {

	// annonation is no option in metav1.ListOptions{}
	listOptions := &metav1.ListOptions{}

	list, err := configMap.retrieveAllConfigMaps(&namespace, listOptions)

	if err != nil {
		return nil, err
	}

	annonationElements := strings.Split(annontations, ",")

	var cmList []corev1.ConfigMap
	for _, cm := range list {
		matchCount := 0

		for _, eachAnnonation := range annonationElements {
			eachAnnonations := strings.Split(eachAnnonation, "=")
			if cm.Annotations[strings.TrimSpace(eachAnnonations[0])] == strings.TrimSpace(eachAnnonations[1]) {
				matchCount++
			}
		}

		if len(annonationElements) == matchCount {
			cmList = append(cmList, cm)
		}
	}

	return cmList, nil
}

func (configMap *ConfigMap) retrieveConfigMapWithSpecificLabels(labels, namespace string) ([]corev1.ConfigMap, error) {

	list, err := configMap.Clientset.CoreV1().ConfigMaps(namespace).List(
		context.Background(),
		metav1.ListOptions{
			LabelSelector: labels,
		})
	if err != nil {
		return nil, err
	}

	return list.Items, nil
}

func (configMap *ConfigMap) retrieveConfigMapByName(configMapName, namespace string) (*corev1.ConfigMap, error) {

	cm, err := configMap.Clientset.CoreV1().ConfigMaps(namespace).Get(context.Background(), configMapName, metav1.GetOptions{})
	if err != nil {
		return nil, err
	}

	return cm, nil
}

func (configMap *ConfigMap) updateConfigMapWithConfigMap(namespace string, cm *corev1.ConfigMap) error {

	_, err := configMap.Clientset.CoreV1().ConfigMaps(namespace).Update(context.Background(), cm, metav1.UpdateOptions{})

	return err
}

// ---

func (configMap *ConfigMap) listAllConfigMap(call bool) {
	if !call {
		return
	}

	namespace := metav1.NamespaceAll
	listOptions := &metav1.ListOptions{}

	list, err := configMap.retrieveAllConfigMaps(&namespace, listOptions)
	if err != nil {
		fmt.Fprintf(os.Stderr, "error fetching configmap: %v\n", err)
		return
	} else {
		fmt.Fprintf(os.Stderr, "fetched a list of configmap\n")
	}

	for _, cm := range list {
		configMap.accessConfigMap(&cm)
	}
}

func (configMap *ConfigMap) createATestConfigMap(call bool, configMapName, namespace string) {
	if !call {
		return
	}

	cm := &corev1.ConfigMap{
		ObjectMeta: metav1.ObjectMeta{
			Name: configMapName,
			Labels: map[string]string{
				"app.kubernetes.io/name": "myapp",
			},
			Annotations: map[string]string{
				"myapp.example.com/managed": "true",
				"myapp.example.com/owner":   "platform-team",
			},
			Namespace: namespace,
		},
		Data: map[string]string{"LOG_LEVEL": "debug"},
	}

	_, err := configMap.Clientset.CoreV1().ConfigMaps(namespace).Create(context.Background(), cm, metav1.CreateOptions{})
	if err != nil {
		fmt.Fprintf(os.Stderr, "error creating configmap: %v\n", err)
		return
	} else {
		fmt.Fprintf(os.Stderr, "a configmap (%v) is created\n", configMapName)
	}
}

func (configMap *ConfigMap) deleteATestConfigMap(call bool, configMapName, namespace string) {
	if !call {
		return
	}

	err := configMap.Clientset.CoreV1().ConfigMaps(namespace).Delete(context.Background(), configMapName, metav1.DeleteOptions{})
	if err != nil {
		fmt.Fprintf(os.Stderr, "error deleting configmap: %v\n", err)
		return
	} else {
		fmt.Fprintf(os.Stderr, "a configmap (%v) is deleted\n", configMapName)
	}
}

func (configMap *ConfigMap) getConfigMapByName(call bool, configMapName, namespace string) {
	if !call {
		return
	}

	cm, err := configMap.retrieveConfigMapByName(configMapName, namespace)
	if err != nil {
		fmt.Fprintf(os.Stderr, "error fetching configmap: %v\n", err)
		return
	}

	configMap.accessConfigMap(cm)
}

func (configMap *ConfigMap) getConfigMapWithSpecificAnnonations(call bool, annontations, namespace string) {
	if !call {
		return
	}

	cmList, err := configMap.retrieveConfigMapWithSpecificAnnonations(annontations, namespace)

	if err != nil {
		fmt.Fprintf(os.Stderr, "error fetching configmap: %v\n", err)
		return
	} else {
		fmt.Fprintf(os.Stderr, "fetched a list of configmap\n")
	}

	for _, cm := range cmList {
		configMap.accessConfigMap(&cm)
	}
}

func (configMap *ConfigMap) getConfigMapWithSpecificLabels(call bool, labels, namespace string) {
	if !call {
		return
	}

	cmList, err := configMap.retrieveConfigMapWithSpecificLabels(labels, namespace)

	if err != nil {
		fmt.Fprintf(os.Stderr, "error fetching configmap: %v\n", err)
		return
	} else {
		fmt.Fprintf(os.Stderr, "fetched a list of configmap\n")
	}

	for _, cm := range cmList {
		configMap.accessConfigMap(&cm)
	}
}

func (configMap *ConfigMap) printAConfigMapIntoJson(call bool, configMapName, namespace string) {
	if !call {
		return
	}

	cm, err := configMap.retrieveConfigMapByName(configMapName, namespace)
	if err != nil {
		fmt.Fprintf(os.Stderr, "error fetching configmap: %v\n", err)
		return
	}

	out, err := json.MarshalIndent(cm, "", "  ")
	if err != nil {
		fmt.Fprintf(os.Stderr, "error to convert a configmap into json: %v\n", err)
	}

	fmt.Println(string(out))
}

func (configMap *ConfigMap) printListConfigMapIntoJson(call, withItem bool, namespace string) {
	if !call {
		return
	}

	var err error
	var list any

	if withItem {
		list, err = configMap.retrieveAllConfigMapItem(&namespace, &metav1.ListOptions{})
	} else {
		list, err = configMap.retrieveAllConfigMaps(&namespace, &metav1.ListOptions{})
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

func (configMap *ConfigMap) updateConfigMapByName(call bool, configMapName, namespace string) {
	if !call {
		return
	}

	cm, err := configMap.retrieveConfigMapByName(configMapName, namespace)
	if err != nil {
		fmt.Fprintf(os.Stderr, "error fetching configmap: %v\n", err)
		return
	}

	cm.Data["LOG_LEVEL"] = "fatal" // change or add a key
	// delete(cm.Data, "OLD_SETTING")  // remove a key

	err = configMap.updateConfigMapWithConfigMap(namespace, cm)
	if err != nil {
		fmt.Fprintf(os.Stderr, "error updating configmap: %v\n", err)
	}

	configMap.getConfigMapByName(true, cm.Name, cm.Namespace)
}

func (configMap *ConfigMap) printAConfigMapIntoYaml(call bool, configMapName, namespace string) {
	if !call {
		return
	}

	cm, err := configMap.retrieveConfigMapByName(configMapName, namespace)
	if err != nil {
		fmt.Fprintf(os.Stderr, "error fetching configmap: %v\n", err)
		return
	}

	out, err := yaml.Marshal(cm)
	if err != nil {
		fmt.Fprintf(os.Stderr, "error to convert a configmap into yaml: %v\n", err)
	}

	fmt.Println(string(out))
}

func (configMap *ConfigMap) Workon(call bool) {
	if !call {
		return
	}

	fmt.Fprintf(os.Stderr, "\n")
	fmt.Fprintf(os.Stderr, "configmap section\n")
	fmt.Fprintf(os.Stderr, "-----------------------------\n")

	configMap.createATestConfigMap(false, "test", "dev")

	configMap.listAllConfigMap(false)

	configMap.getConfigMapByName(false, "test", "dev")

	configMap.getConfigMapWithSpecificAnnonations(false, "meta.helm.sh/release-name=tempo,meta.helm.sh/release-namespace=opentelemetry", "")

	configMap.getConfigMapWithSpecificLabels(false, "app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=loki", "")

	configMap.updateConfigMapByName(true, "test", "dev")

	configMap.printAConfigMapIntoJson(false, "test", "dev")

	configMap.printListConfigMapIntoJson(false, false, "dev")

	configMap.printAConfigMapIntoYaml(false, "test", "dev")

	configMap.deleteATestConfigMap(false, "test", "dev")

	fmt.Fprintf(os.Stderr, "-----------------------------\n")
}
