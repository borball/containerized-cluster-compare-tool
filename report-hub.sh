#!/bin/bash

set -e
set -u
spoke=$1

if [ -z "$spoke" ]; then
  echo "Usage: $0 <spoke cluster>"
  echo "   <spoke cluster> is required"
  echo "Example: $0 sno131"
  exit 1
fi

if [ $(oc get managedcluster.cluster.open-cluster-management.io  |grep $spoke | wc -l) -eq 1 ]; then
  oc get secret -n ${spoke} ${spoke}-admin-kubeconfig -o jsonpath={.data.kubeconfig} |base64 -d > kubeconfig-${spoke}.yaml
  export KUBECONFIG=kubeconfig-${spoke}.yaml

  version=$(oc version -o yaml |grep openshiftVersion |cut -d: -f2|cut -d " " -f2 |cut -d "." -f1-2)
  metadata_rds="metadata-rds.yaml"
  metadata_blueprint="metadata-blueprint.yaml"

  echo "------------------------------------------------------------------------------------------------------------------------"
  oc get clusterversion
  echo
  oc get policy -A -o=custom-columns=NS:.metadata.namespace,NAME:.metadata.name,"REMEDIATION ACTION":.spec.remediationAction,"COMPLIANCE STATE":.status.compliant,WAVE:.metadata.annotations."ran\.openshift\.io\/ztp-deploy-wave" --sort-by={.metadata.annotations."ran\.openshift\.io\/ztp-deploy-wave"}
  echo
  echo "---------------------- comparing cluster: $spoke with kube-compare-reference/release-$version/$metadata_rds ----------------------"

  echo
  oc cluster-compare -r kube-compare-reference/release-$version/$metadata_rds
  echo
  echo "------------------------------------------------------------------------------------------------------------------------"
  echo
  echo "---------------------- comparing cluster: $spoke with kube-compare-reference/release-$version/$metadata_blueprint ----------------------"
  echo
  oc cluster-compare -r kube-compare-reference/release-$version/$metadata_blueprint
else
  echo "cluster $spoke not exist, please check."
fi

exit 0