ARG BASE_IMAGE
ARG KUBE_COMPARE_VERSION=v0.12.0
FROM ${BASE_IMAGE} AS download
ARG KUBE_COMPARE_VERSION
RUN dnf install -y wget && \
    wget -q "https://github.com/openshift/kube-compare/releases/download/${KUBE_COMPARE_VERSION}/kube-compare_linux_amd64.tar.gz" -O kube-compare.tar.gz && \
    tar xzf kube-compare.tar.gz && \
    find . -name 'kubectl-cluster_compare' -type f -exec cp {} /usr/local/bin/ \; && \
    kubectl-cluster_compare -h

FROM ${BASE_IMAGE}
COPY --from=download /usr/local/bin/kubectl-cluster_compare /usr/local/bin/kubectl-cluster_compare

COPY kube-compare-reference kube-compare-reference

COPY report-hub.sh report-hub.sh
COPY report-spoke.sh report-spoke.sh
RUN chmod +x report-hub.sh
RUN chmod +x report-spoke.sh

CMD bash