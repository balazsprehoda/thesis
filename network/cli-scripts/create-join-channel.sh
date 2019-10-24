#!/bin/bash

export CHANNEL_NAME=mychannel
export ORDERER_URL=ord1-hlf-ord.orderers.svc.cluster.local:7050
export CORE_PEER_LOCALMSPID=Org1MSP
export CORE_PEER_MSPCONFIGPATH=/fabric/config/crypto/org1/msp
export CORE_PEER_ADDRESS=peer1-hlf-peer.org1.svc.cluster.local:7051
export FABRIC_CFG_PATH=/etc/hyperledger/fabric

# Create channel
peer channel create -o ${ORDERER_URL} -c ${CHANNEL_NAME} -f /fabric/config/channel-artifacts/mychannel.tx

# Join peers
for ORG_NUM in 1 2 3
do
    export CORE_PEER_LOCALMSPID=Org${ORG_NUM}MSP
    export CORE_PEER_MSPCONFIGPATH=/fabric/config/crypto/org${ORG_NUM}/msp
    export CORE_PEER_ADDRESS=peer${ORG_NUM}-hlf-peer.org${ORG_NUM}.svc.cluster.local:7051
    peer channel fetch newest -o ${ORDERER_URL} -c ${CHANNEL_NAME}
    peer channel join -b ${CHANNEL_NAME}_newest.block
    rm -rf /${CHANNEL_NAME}_newest.block
done

# Update anchor peers
for ORG_NUM in 1 2 3
do
    export CORE_PEER_LOCALMSPID=Org${ORG_NUM}MSP
    export CORE_PEER_MSPCONFIGPATH=/fabric/config/crypto/org${ORG_NUM}/msp
    export CORE_PEER_ADDRESS=peer${ORG_NUM}-hlf-peer.org${ORG_NUM}.svc.cluster.local:7051
    peer channel update -o ${ORDERER_URL} -c ${CHANNEL_NAME} -f /fabric/config/channel-artifacts/Org${ORG_NUM}MSPanchors.tx
done