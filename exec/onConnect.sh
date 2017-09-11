#!/bin/bash

function onConnectedUser() {
  echo "User $1 successfully connected" >> /var/log/proftpd/exec_onConnect.log
}

while test $# -gt 0; do
  case "$1" in
    -u|--user)
      shift
      onConnectedUser $1
      exit 0
      ;;
     *)
      shift
      ;;
  esac
done
