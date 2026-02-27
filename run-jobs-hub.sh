#!/bin/bash

image="${IMAGE:-quay.io/bzhai/containerized-cluster-compare-tool}"
NS=default

usage(){
  echo "Usage :   $0 <spoke cluster>"
  echo "   <spoke cluster> is optional, if not present, it will run cluster compare tool towards all the managed clusters."
  echo "Example :   $0 sno131"
  echo "Example :   $0"
}


create_sa(){
  cat <<EOF | oc apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: cluster-compare-reporter-sa
  namespace: ${NS}
EOF
}

delete_sa(){
  oc delete -n ${NS} sa cluster-compare-reporter-sa
}

delete_cluster_role_binding(){
  oc delete ClusterRoleBinding cluster-compare-reporter
}

create_cluster_role_binding(){
  cat <<EOF | oc apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: cluster-compare-reporter
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: cluster-compare-reporter-sa
    namespace: ${NS}
EOF
}

delete_job(){
  spoke=$1
  oc delete job -n ${NS} cluster-compare-reporter-$spoke
}

create_job(){
  spoke=$1
  cat <<EOF | oc apply -f -
apiVersion: batch/v1
kind: Job
metadata:
  name: cluster-compare-reporter-$spoke
  namespace: ${NS}
spec:
  template:
    spec:
      restartPolicy: Never
      serviceAccountName: cluster-compare-reporter-sa
      containers:
        - name: reporter
          image: $image
          imagePullPolicy: Always
          command: ["/report-hub.sh"]
          args:
            - $spoke
  backoffLimit: 2

EOF

  oc wait --for=condition=complete --timeout=300s job/cluster-compare-reporter-$spoke -n ${NS}

  echo ---------------------------------------------------------------------------------------------------------------------------------
  oc logs $(oc get po --selector job-name="cluster-compare-reporter-$spoke" -o name) -n ${NS}
  echo ---------------------------------------------------------------------------------------------------------------------------------

}

delete_job(){
  oc delete job -n ${NS} cluster-compare-reporter-$1
}

if [[ ( $@ == "--help") ||  $@ == "-h" ]]
then
  usage
  exit
fi

create_sa
create_cluster_role_binding

if [ $# -lt 1 ]; then
  for spoke in $(oc get managedcluster.cluster.open-cluster-management.io -o jsonpath={..metadata.name} -l '!local-cluster' -n ${NS})
  do
    create_job $spoke
    delete_job $spoke
    echo
  done
else
  create_job $1
  delete_job $1
fi

delete_cluster_role_binding
delete_sa
