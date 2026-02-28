#!/bin/bash
set -e
set -u
image="${IMAGE:-quay.io/bzhai/containerized-cluster-compare-tool}"
NS=default

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
  oc delete -n ${NS} sa cluster-compare-reporter-sa --ignore-not-found=true
}

delete_cluster_role_binding(){
  oc delete ClusterRoleBinding cluster-compare-reporter --ignore-not-found=true
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
  oc delete job -n ${NS} cluster-compare-reporter --ignore-not-found=true
}

cleanup(){
  delete_job || true
  delete_cluster_role_binding || true
  delete_sa || true
}
trap cleanup EXIT

create_job(){
  cat <<EOF | oc apply -f -
apiVersion: batch/v1
kind: Job
metadata:
  name: cluster-compare-reporter
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
          command: ["/report-spoke.sh"]
  backoffLimit: 2

EOF

oc wait -n ${NS} --for=condition=complete --timeout=10m job/cluster-compare-reporter

oc logs -n ${NS} $(oc get -n ${NS} po --selector job-name="cluster-compare-reporter" -o name)
}

create_sa
create_cluster_role_binding
create_job