#/bin/bash
oc login -u kubeadmin -p cznQP-n4pBk-cnXTg-nkevH https://api.crc.testing:6443
oc delete project pipeline-tasks-demo 
oc new-project pipeline-tasks-demo 
oc apply -f tasks/apply_manifest_task.yaml
oc apply -f tasks/maven-build-task.yaml
oc apply -f tasks/maven-configmap.yaml
oc apply -f tasks/pipeline.yaml
oc apply -f tasks/resources.yaml 
oc apply -f tasks/secret.yaml
oc apply -f tasks/serviceacount_botbuilder.yaml
oc apply -f tasks/update_deployment_task.yaml
oc apply -f tasks/oc-task.yaml

oc adm policy add-role-to-user system:image-builder kubeadmin
oc adm policy add-role-to-user system:image-builder developer
oc secrets link pipeline basic-user-pass

#sleep 600 #Sleep long enough for pods to be created, then expose it
#oc expose svc/tekton-tasks-demo
