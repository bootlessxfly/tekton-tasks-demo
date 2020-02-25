#/bin/bash
# set GUID with first parm
GUID=$1
# Install the intial nexus and pause it.
oc new-project ${GUID}-nexus --display-name "${GUID} Shared Nexus"
oc new-app sonatype/nexus3:latest --name=nexus
oc expose svc nexus
oc rollout pause dc nexus

# Change Nexus from rolling to recreate and set limits
oc patch dc nexus --patch='{ "spec": { "strategy": { "type": "Recreate" }}}'
oc set resources dc nexus --limits=memory=2Gi,cpu=2 --requests=memory=1Gi,cpu=500m

# Add persisitent store (PVC)
oc set volume dc/nexus --add --overwrite --name=nexus-volume-1 --mount-path=/nexus-data/ --type persistentVolumeClaim --claim-name=nexus-pvc --claim-size=10Gi

# Setup Liveness and readiness
oc set probe dc/nexus --liveness --failure-threshold 3 --initial-delay-seconds 60 -- echo ok
oc set probe dc/nexus --readiness --failure-threshold 3 --initial-delay-seconds 60 --get-url=http://:8081/

# Finish rollout and wait for everything to finish
oc rollout resume dc nexus
sleep 120

#Get pod name and nexus password and run redhat maven automation script
pod=$(oc get pods | grep nexus-1 | awk '!/nexus-1-deploy/' | awk '{print $1}')
export NEXUS_PASSWORD=$(oc rsh $pod cat /nexus-data/admin.password)
curl -o setup_nexus3.sh -s https://raw.githubusercontent.com/redhat-gpte-devopsautomation/ocp_advanced_development_resources/master/nexus/setup_nexus3.sh
chmod +x setup_nexus3.sh
./setup_nexus3.sh admin $NEXUS_PASSWORD http://$(oc get route nexus --template='{{ .spec.host }}')
rm setup_nexus3.sh
