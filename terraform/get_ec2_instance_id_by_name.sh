#!/bin/bash

result=$(aws ec2 describe-instances --filter Name=tag:Name,Values=$1 2>&1)

if [ $? -eq 0 ]; then
  instanceId=$(echo $result | jq -r ".Reservations[0].Instances[0].InstanceId")
  echo -n $instanceId
else
  echo -n null
fi
