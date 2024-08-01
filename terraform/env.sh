#!/bin/bash

jq --null-input --arg sshkey "$AWS_SSH_PRIVATE_KEY" '{"ssh-key": $sshkey}'
