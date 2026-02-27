#!/bin/bash

# browse the latest release of kube-compare on github https://github.com/openshift/kube-compare/tags
# download and install the binary to /usr/local/bin/

latest_release=$(curl -s https://api.github.com/repos/openshift/kube-compare/releases/latest | jq -r '.tag_name')
echo "Latest release: $latest_release"

download_url=$(curl -s https://api.github.com/repos/openshift/kube-compare/releases/latest | jq -r '.assets[] | select(.name? | match("kube-compare_linux_amd64")) | .browser_download_url')
echo "Download URL: $download_url"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
curl -sL "$download_url" -o "$tmpdir/kube-compare.tar.gz"
tar -xzf "$tmpdir/kube-compare.tar.gz" -C "$tmpdir" kubectl-cluster_compare
sudo install -m 755 "$tmpdir/kubectl-cluster_compare" /usr/local/bin/

echo "Kube-compare downloaded successfully"
#try it out 
oc cluster-compare --help