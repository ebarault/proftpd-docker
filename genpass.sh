#!/bin/bash

package="./genpass.sh"

function help {
  echo "$package - generate passwords for proftpd server"
  echo " "
  echo "password formula is: [ SHA256( SALT + password ) ].hex64"
  echo " "
  echo "usage:"
  echo "$package -s path/to/salt password"
  echo "$package --salt path/to/salt password"
}


function generatePassword() {
  { echo -n $1; echo -n `cat $SALT_FILE`; } | openssl dgst -binary -sha256 | openssl enc -base64 -A
}

if [ "${1}" != '-s' ] && [ "${1}" != '-h' ]; then
  echo " "
  echo "Please specify the path to the salt file"
  echo " "
  echo "Example : $package -s path/to/salt password"
  echo " "
  exit -1
else
  if [ "${1}" = '-h' ]; then
    help
    exit 0
  fi
  shift
  SALT_FILE=$1
  shift
  generatePassword $1
fi
