#!/bin/bash

# INFO: $1   : Beinhaltet der erste Parameter, der dem Script übergeben wird
#       2>&1 : Sendet Errors nach /dev/null, damit das Script nicht beendet wird
result=$(aws ec2 describe-instances --filter Name=tag:Name,Values="$1" 2>&1)

if [ $? -eq 0 ]; then
  echo "$result" | jq -c ".Reservations" | while read -r reservation; do
    echo "$reservation" | jq -rc ".[].Instances[0].InstanceId" | while read -r instanceId; do
      terraform import aws_instance."$1" "$instanceId" 2>&1
    done
  done
fi
