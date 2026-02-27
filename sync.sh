#!/bin/bash

basedir="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
workspace=$(mktemp -d)
upstream_repo_old=git@github.com:openshift-kni/cnf-features-deploy.git
upstream_repo_new=git@github.com:openshift-kni/telco-reference.git

branch=$1
supported_branches="release-4.14 release-4.16 release-4.18 release-4.20 release-4.21 release-4.22"
if ! echo "$supported_branches" | grep -q "$branch"; then
  echo "branch $branch is not supported, please use one of the following: $supported_branches"
  exit 1
fi

sync(){
  cd $workspace

  if [ "$branch" == "release-4.14" ] || [ "$branch" == "release-4.16" ] || [ "$branch" == "release-4.18" ]; then
    git clone $upstream_repo_old reference-$branch
    cd reference-$branch
    git checkout $branch
    cd ztp/kube-compare-reference/
    mkdir -p $basedir/kube-compare-reference/$branch/rds/
    rsync -ar ./ $basedir/kube-compare-reference/$branch/rds/

  else
    git clone $upstream_repo_new reference-$branch
    cd reference-$branch
    git checkout $branch
    cd telco-ran/configuration/kube-compare-reference/
    mkdir -p $basedir/kube-compare-reference/$branch/rds/
    rsync -ar ./ $basedir/kube-compare-reference/$branch/rds/

  fi

  cp $basedir/kube-compare-reference/$branch/rds/metadata.yaml $basedir/kube-compare-reference/$branch/metadata-rds.yaml
  #replace - path: with - path: rds/
  sed -i 's/- path: /- path: rds\//g' $basedir/kube-compare-reference/$branch/metadata-rds.yaml
  # replace - functions/ with - rds/functions/
  sed -i 's/- functions\//- rds\/functions\//g' $basedir/kube-compare-reference/$branch/metadata-rds.yaml
}

sync