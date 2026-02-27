#!/bin/bash

version=$(oc version -o yaml |grep openshiftVersion |cut -d: -f2|cut -d " " -f2 |cut -d "." -f1-2)

metadata_rds="metadata-rds.yaml"
metadata_blueprint="metadata-blueprint.yaml"

echo "------------------------------------------------------------------------------------------------------------------------"
oc get clusterversion
echo
oc get policy -A -o=custom-columns=NS:.metadata.namespace,NAME:.metadata.name,"REMEDIATION ACTION":.spec.remediationAction,"COMPLIANCE STATE":.status.compliant,WAVE:.metadata.annotations."ran\.openshift\.io\/ztp-deploy-wave" --sort-by={.metadata.annotations."ran\.openshift\.io\/ztp-deploy-wave"}
echo
echo "---------------------- comparing cluster with kube-compare-reference/release-$version/$metadata_rds ----------------------"
echo
oc cluster-compare -r kube-compare-reference/release-$version/$metadata_rds
echo
echo "---------------------- comparing cluster with kube-compare-reference/release-$version/$metadata_blueprint ----------------------"
echo
oc cluster-compare -r kube-compare-reference/release-$version/$metadata_blueprint
echo
echo "------------------------------------------------------------------------------------------------------------------------"

exit 0


