#!/bin/bash

echo "Custom script for OpenShift Virtualization Lab"

oc whoami --show-server=true

# Add IDP
echo "Add IDP"
oc apply -f gitops/htpasswd.yaml
oc patch oauth cluster --type=merge -p '{"spec":{"identityProviders":[{"name":"lab-beginner","mappingMethod":"claim","type":"HTPasswd","htpasswd":{"fileData":{"name":"htpass-beginner"}}},{"name":"lab-advanced","mappingMethod":"claim","type":"HTPasswd","htpasswd":{"fileData":{"name":"htpasswd"}}}]}}'