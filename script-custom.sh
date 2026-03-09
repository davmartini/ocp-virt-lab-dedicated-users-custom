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

# Install Kasten
echo "Install Kasten"
oc apply -f gitops/kasten-io.yaml
oc apply -f gitops/kasten-io-opg.yaml
oc apply -f gitops/kasten-io-sub.yaml
sleep 90
oc apply -f gitops/kasten-io-int.yaml
sleep 90

# Create Bucket
echo "Create Kasten Bucket"
oc apply -f gitops/bucket.yaml

# Create Kasten Profile
echo "Create Kasten Profile"
AK=$(oc get secret/kasten-backup-s3 -n kasten-io -o jsonpath='{.data.AWS_ACCESS_KEY_ID}' | base64 -d)
SK=$(oc get secret/kasten-backup-s3 -n kasten-io -o jsonpath='{.data.AWS_SECRET_ACCESS_KEY}' | base64 -d)
oc create secret generic --type=secrets.kanister.io/aws k10secret-s3 --from-literal=aws_access_key_id="$AK" --from-literal=aws_secret_access_key="$SK" -n kasten-io
oc apply -f kasten-profile-s3.yaml
oc annotate storageclass ocs-external-storagecluster-ceph-rbd k10.kasten.io/sc-supports-block-mode-exports=true
oc annotate storageclass ocs-external-storagecluster-ceph-rbd-immediate k10.kasten.io/sc-supports-block-mode-exports=true
oc annotate volumesnapshotclass ocs-external-storagecluster-rbdplugin-snapclass k10.kasten.io/is-snapshot-class=true

# Role Kasten
echo "Apply Kasten permissions"
oc apply -f gitops/kasten-cluster-role.yaml
oc apply -f gitops/kasten-cluter-role-policies.yaml
oc apply -f gitops/role-binding-kasten.yaml
oc apply -f gitops/kasten-binding.yaml
oc apply -f gitops/kasten-binding-s3.yaml


# Add Specific roles
echo "Add Specific roles"
oc adm policy add-role-to-user admin user01 -n project-1
oc adm policy add-role-to-user admin user01 -n udn-project-1
oc adm policy add-role-to-user admin user01 -n openshift
oc adm policy add-role-to-user view user01 -n kasten-io
oc adm policy add-role-to-user kubevirt.io:dm user01 -n project-1
oc adm policy add-role-to-user kubevirt.io:dm user01 -n udn-project-1
oc adm policy add-role-to-user edit user01 -n openshift-migration
oc adm policy add-cluster-role-to-user cluster-admin admin01

# Add Specific roles 2
oc apply -f gitops/nmstate-role.yaml
oc apply -f gitops/nmstate-role-binding.yaml



