#!/bin/bash

### Retreives or writes the id of a notification for a given tag to a tmp file
###
### Author: Matthias Seiffert
###
### Usage: notification_id.sh tag [id]
###   if you don't give an id we will only retreive it (or 0 if not stored)
###   if you do give an id we will store it and return it

timeout=${NOTIFICATION_TIMEOUT:-8}
tag=$1
id=$2

file=/tmp/notification_ids/$tag

mkdir -p /tmp/notification_ids

if [[ -n $id ]]
then
    # id given: store it
    echo $id > $file
fi

[ ! -f $file ] && echo 0 && exit

let modified=$(date +%s)-$(date -r $file +%s)

# return id if written in the last $timeout seconds, 0 otherwise
if [[ $modified -gt $timeout ]]
then
    echo 0
    rm $file
else
    cat $file
fi
