#!/bin/sh

LOC=`echo $1 | sed 's/-//g'`

locale -a | sed 's/-//g' | grep -i "${LOC}" 2>&1 > /dev/null

if [ "$?" = "0" ]
then
  echo "yes"
else
  echo "no"
fi
