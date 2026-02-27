# Reference (DU) validation with kube-compare

Scripts and image to run the [kube-compare](https://github.com/openshift/kube-compare) tool (oc plugin) against [RAN reference configurations 4.18 or older](https://github.com/openshift-kni/cnf-features-deploy/tree/master/ztp/kube-compare-reference) and [RAN reference configurations 4.20 or later](https://github.com/openshift-kni/telco-reference/tree/main/telco-ran/configuration/kube-compare-reference)for DU validation.

**Image:** `quay.io/bzhai/containerized-cluster-compare-tool:20260227`

## Quick start

- **From spoke:** `./report-spoke.sh`
- **From hub (one spoke):** `./report-hub.sh <spoke-name>`
- **Hub as K8s job (one or all spokes):** `./run-jobs-hub.sh [spoke-name]`
- **Spoke as K8s job:** `./run-job-spoke.sh`

Scripts detect the OpenShift version and choose the correct reference metadata, it will compare both towards RDS and blueprint.

**Full usage, and example output:** [USAGE.md](USAGE.md)
