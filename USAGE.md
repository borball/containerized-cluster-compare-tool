# Usage guide

This document describes how to run the cluster-compare scripts and shows example output from real test runs.

---

## 1. Direct report scripts (no K8s jobs)

### report-spoke.sh

Run on a **spoke** (set `KUBECONFIG` to that cluster, e.g. `sno146`). No arguments.

```shell
#switch kubeconfig to your target spoke cluster first
./report-spoke.sh
```

### report-hub.sh

Run on the **hub** (e.g. `acm1`). **A spoke name is required** — do not run without an argument.

```shell
#switch kubeconfig to your hub cluster first
./report-hub.sh sno146
```

---

## 2. K8s jobs on Hub

From the **hub** context (`acm1`):

- **One spoke:** `./run-jobs-hub.sh sno146`
- **All managed clusters:** `./run-jobs-hub.sh`

The script creates a job, streams cluster-compare output, then deletes the job and RBAC.

---

## 3. K8s job on Spoke

From the **spoke** context (`sno146`):

```shell
./run-job-spoke.sh
```

Creates a one-off job on that cluster, streams the comparison, then cleans up.

---

## Example: testing on target clusters

**Spoke (sno146):**

```shell
sno146
./report-spoke.sh
```

**Hub, compare spoke sno146:**

```shell
acm1
./report-hub.sh sno146
```
