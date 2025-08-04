#!/bin/bash

logged_in_user=$(whoami)
if [[ $logged_in_user != root ]];then
  echo >&2 Please login as root before running this script
  exit 4
fi	

dnf install -y git

cp ./vimrc ~/.vimrc

git config --global user.name "Brent Denny"
git config --global user.email "brent.denny@lumifygroup.com"
git config --global init.defaultBranch main


