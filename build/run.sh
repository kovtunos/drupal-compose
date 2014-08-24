#!/usr/bin/env bash

case "$1" in
  init)
    cp /app/dev.yaml /context/dev.yaml
    ;;
  up)
    printf "$(/app/dev.js up /context)"
    ;;
  destroy)
    printf "$(/app/dev.js destroy /context)"
    ;;
  get)
    case "$2" in
      database)
        echo ${SSH_PRIVATE_KEY} | ssh -i /dev/stdin ${SSH_USER}@${SSH_HOSTNAME} dev-master get database $3
        ;;
    esac
    ;;
esac
