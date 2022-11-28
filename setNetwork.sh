#!/bin/bash

NETWORK=$1

case ${NETWORK} in
  "mainnet"|"gnosis"|"goerli")
    ;;
  *)
    echo "Invalid network"
    exit
    ;;
esac

for file in \
    docker-compose.yml \
    dappnode_package.json \
    avatar.png
do
    BASENAME=${file%.*}
    EXT=${file##*.}
    rm -f $file
    ln -sf build/${BASENAME}-${NETWORK}.${EXT} $file
done