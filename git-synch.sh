#!/bin/bash
CurrentPath=$(pwd)
SynchLocation="/C/git-synch/"
BundleLocation="/C/git-synch/project.bundle"
RemoteA="https://github.com/andriybuday/RepoA_DF.git"
RepoA="RepoA"
RemoteB="https://github.com/andriybuday/RepoB.git"
RepoB="RepoB"

rm -rf $SynchLocation$RepoA
rm -rf $SynchLocation$RepoB

if git clone $RemoteA $SynchLocation$RepoA; then
  RemoteAvailable=$RemoteA
  RepoThis=$RepoA
  RepoOther=$RepoB
else
  if git clone $RemoteB $SynchLocation$RepoB; then
    RemoteAvailable=$RemoteB
    RepoThis=$RepoB
    RepoOther=$RepoA
  else
    echo "ERROR: Cannot clone from "$RemoteA" or "$RemoteB
    exit 1
  fi
fi

echo "Synchronizing from " $BundleLocation " into " $RemoteAvailable

git clone $BundleLocation $SynchLocation$RepoOther
cd $SynchLocation$RepoOther
git fetch
git checkout master

cd $SynchLocation$RepoThis

git remote add $RepoOther $SynchLocation$RepoOther
git fetch $RepoOther
if git merge --allow-unrelated-histories $RepoOther/master; then
  if git push; then
    git bundle create $BundleLocation --branches --tags
    echo "";
    echo "SUCCESS"
  else
    echo "ERROR: Cannot push to remote "$RemoteAvailable
  fi
else
  echo ""
  echo "ERROR: Cannot merge "$RepoOther" into "$RepoThis
  echo "Please resolve conflicts in "$SynchLocation$RepoThis" and push to "$RemoteAvailable" manually"
fi
git remote remove $RepoOther;
cd $CurrentPath;