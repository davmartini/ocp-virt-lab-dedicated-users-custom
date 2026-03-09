#!/bin/bash

echo "Custom script for OpenShift Virtualization Lab"

oc whoami --show-server=true

# Add IDP
echo "Add IDP"
oc apply -f gitops/htpasswd.yaml
oc patch oauth cluster --type=merge -p '{"spec":{"identityProviders":[{"name":"lab-beginner","mappingMethod":"claim","type":"HTPasswd","htpasswd":{"fileData":{"name":"htpass-beginner"}}},{"name":"lab-advanced","mappingMethod":"claim","type":"HTPasswd","htpasswd":{"fileData":{"name":"htpasswd"}}}]}}'

# Add Virtu Role
echo "Add Virtu Role"
oc apply -f gitops/clusterrole.yaml

# Create new namespace
echo "Create new namespace"
oc apply -f gitops/project-1.yaml
oc apply -f gitops/udn-project-1.yaml


# Install NMSTATE
echo "Install NMSTATE"
oc apply -f gitops/openshift-nmstate.yaml
oc apply -f gitops/nmstate-opg.yaml
oc apply -f gitops/nmstate-sub.yaml
sleep 90
oc apply -f gitops/nmstate-int.yaml


# Add Specific roles
echo "Add Specific roles"
oc adm policy add-role-to-user admin user01 -n project-1
oc adm policy add-role-to-user admin user01 -n udn-projet-1
oc adm policy add-role-to-user admin user01 -n openshift
oc adm policy add-role-to-user kubevirt.io:dm user01 -n project-1
oc adm policy add-role-to-user kubevirt.io:dm user01 -n udn-projet-01
oc adm policy add-role-to-user edit user01 -n openshift-migration
oc adm policy add-cluster-role-to-user cluster-admin admin01


