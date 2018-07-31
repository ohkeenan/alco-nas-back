#!/bin/bash

. /opt/alco-nas-back/settings.cfg

emails=($sendto)
for i in "${emails[@]}"
do
    (( count++ ))
    tomails+="--data-urlencode Destination.ToAddresses.member.$count=$i "
done

date="$(date -R)"
signature="$(echo -n "$date" | openssl dgst -sha256 -hmac "$priv_key" -binary | base64 -w 0)"
auth_header="X-Amzn-Authorization: AWS3-HTTPS AWSAccessKeyId=$access_key, Algorithm=HmacSHA256, Signature=$signature"
endpoint="https://email.us-west-2.amazonaws.com/"

action="Action=SendEmail"
source="Source=$FROM"
subject="Message.Subject.Data=$SUBJECT"
message="Message.Body.Text.Data=$MESSAGE"

curl -v -X POST -H "Date: $date" -H "$auth_header" --data-urlencode "$message" $tomails --data-urlencode "$source" --data-urlencode "$action" --data-urlencode "$subject"  "$endpoint"
