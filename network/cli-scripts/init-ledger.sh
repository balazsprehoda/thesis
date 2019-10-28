#!/bin/bash

CHAINCODE_NAME=go
CHAINCODE_VERSION=1.0
CHANNEL_NAME=mychannel
FABRIC_CFG_PATH=/etc/hyperledger/fabric
ORDERER_URL=ord1-hlf-ord.orderers.svc.cluster.local:7050

if [ -z "$ORG_NUM" ]
then
    export ORG_NUM=1
fi

export CORE_PEER_LOCALMSPID=Org${ORG_NUM}MSP
export CORE_PEER_MSPCONFIGPATH=/fabric/config/crypto/org${ORG_NUM}/msp
export CORE_PEER_ADDRESS=peer${ORG_NUM}-hlf-peer.org${ORG_NUM}.svc.cluster.local:7051

peer chaincode invoke -o ${ORDERER_URL} -C ${CHANNEL_NAME} -n ${CHAINCODE_NAME} -c "{\"Args\":[\"initLedger\"]}"