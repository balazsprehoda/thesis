#!/bin/bash

export CHANNEL_NAME=mychannel
export CACERT_ORDERER=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example-network.com/orderers/orderer.example-network.com/tls/ca.crt

if [ $# == 1 ];
    then
        peer chaincode invoke -o orderer.example-network.com:7050 -C $CHANNEL_NAME -n dummycc -c "{\"Args\":[\"queryValue\",\"$1\"]}" --tls --cafile $CACERT_ORDERER
    else
        echo "Usage: queryHash.sh <key>"
fi
