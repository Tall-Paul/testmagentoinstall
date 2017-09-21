#!/bin/bash
branchfile="./deployment/website/http/branch.txt"
repo=`git config --get remote.origin.url`

if [ -f $branchfile ]; then
  branchtext=$(<$branchfile)
  echo "Current build is $branchtext"
else
  echo "No build ready for deployment"
fi
read -p "(Re)build before deploy? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
  echo "Enter branch to Build:"
  git branch -r | sed "s/ origin\///" | tail -n +2
  echo
  read branch
  sudo mv deployment deployment-old
  sudo rm -rf deployment-old
  mkdir deployment
  cd deployment
  git clone -b $branch --single-branch $repo
  cd website
  git submodule init
  git submodule update
  ./rebuild.sh
  echo $branch > http/branch.txt
  cd ../..
fi


echo "Enter server to deploy to: [dev,staging,production,none]"
read config

if [ ! -f ./configs/$config/include.sh ]; then
  echo "No config found for $config, exiting"
  exit 0;
fi

source ./configs/$config/include.sh

cd deployment/website
branch=$(<./http/branch.txt)

release="`date +%Y%m%d%H%M%S`"
echo "Ready to deploy $branch to $config"
read -p "Are you sure? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
  echo "removing old releases..."
  ssh $host "cd $root/releases && ls -t | tail -n +3 | xargs sudo rm -rf"
  ssh $host "mkdir $root/releases/$release"
  echo "Copying files, might take a while..."
  rsync -avzLq http $host:$root/releases/$release
  echo "Making links...."
  ssh $host "ln -sfn $root/config/local.xml $root/releases/$release/http/app/etc/local.xml"
  #ssh $host "cd $root/releases/$release/http && find $root/static/ -maxdepth 1 -mindepth 1 | xargs ln -sfn"
  ssh $host "ln -sfn $root/static/media/ $root/releases/$release/http/"
  ssh $host "ln -sfn $root/static/feeds/ $root/releases/$release/http/"
  ssh $host "ln -sfn $root/static/delivery.json $root/releases/$release/http/"
  ssh $host "sudo chown -R $user:$group $root/releases/$release"
  read -p "Make web symlink? " -n 1 -r
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    ssh $host "ln -sfn $root/releases/$release/http $root/htdocs"

    read -p "Run update scripts? " -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
      ssh $host "cd $root && ./n98-magerun.phar sys:setup:run"
    fi

    read -p "Clear cache?" -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
      ssh $host "cd $root && ./n98-magerun.phar cache:clean"
    fi
  fi







fi
