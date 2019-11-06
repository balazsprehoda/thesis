#!/bin/bash

export CHANNEL_NAME=mychannel
export ORDERER_URL=ord2-hlf-ord.orderers.svc.cluster.local:7050
export CORE_PEER_LOCALMSPID=Org1MSP
export CORE_PEER_MSPCONFIGPATH=/fabric/config/crypto/peerOrganizations/org1.svc.cluster.local/users/Admin@org1.svc.cluster.local/msp
export CORE_PEER_ADDRESS=peer1-hlf-peer.org1.svc.cluster.local:30151
export FABRIC_CFG_PATH=/etc/hyperledger/fabric
export ORDERER_CAFILE=/fabric/config/crypto/ordererOrganizations/orderers.svc.cluster.local/orderers/ord2-hlf-ord.orderers.svc.cluster.local/tls/ca.crt
export CORE_PEER_TLS_ROOTCERT_FILE=/fabric/config/crypto/peerOrganizations/org1.svc.cluster.local/peers/peer1-hlf-peer.org1.svc.cluster.local/tls/ca.crt

# Create channel
peer channel create -o ${ORDERER_URL} -c ${CHANNEL_NAME} -f /fabric/config/channel-artifacts/mychannel.tx --tls --cafile $ORDERER_CAFILE
echo "################# CHANNEL CREATED #################"

# Join peers
for ORG_NUM in 1 2 3
do
    export CORE_PEER_LOCALMSPID=Org${ORG_NUM}MSP
    export CORE_PEER_MSPCONFIGPATH=/fabric/config/crypto/peerOrganizations/org${ORG_NUM}.svc.cluster.local/users/Admin@org${ORG_NUM}.svc.cluster.local/msp
    export CORE_PEER_ADDRESS=peer${ORG_NUM}-hlf-peer.org${ORG_NUM}.svc.cluster.local:30${ORG_NUM}51
    export CORE_PEER_TLS_ROOTCERT_FILE=/fabric/config/crypto/peerOrganizations/org${ORG_NUM}.svc.cluster.local/peers/peer${ORG_NUM}-hlf-peer.org${ORG_NUM}.svc.cluster.local/tls/ca.crt

    peer channel fetch newest -o ${ORDERER_URL} -c ${CHANNEL_NAME} --tls --cafile $ORDERER_CAFILE
    peer channel join -b ${CHANNEL_NAME}_newest.block
    rm -rf /${CHANNEL_NAME}_newest.block
done

# Update anchor peers
for ORG_NUM in 1 2 3
do
    export CORE_PEER_LOCALMSPID=Org${ORG_NUM}MSP
    export CORE_PEER_MSPCONFIGPATH=/fabric/config/crypto/peerOrganizations/org${ORG_NUM}.svc.cluster.local/peers/peer${ORG_NUM}-hlf-peer.org${ORG_NUM}.svc.cluster.local/msp
    export CORE_PEER_ADDRESS=peer${ORG_NUM}-hlf-peer.org${ORG_NUM}.svc.cluster.local:30${ORG_NUM}51
    export CORE_PEER_TLS_ROOTCERT_FILE=/fabric/config/crypto/peerOrganizations/org${ORG_NUM}.svc.cluster.local/peers/peer${ORG_NUM}-hlf-peer.org${ORG_NUM}.svc.cluster.local/tls/ca.crt

    peer channel update -o ${ORDERER_URL} -c ${CHANNEL_NAME} -f /fabric/config/channel-artifacts/Org${ORG_NUM}MSPanchors.tx --tls --cafile $ORDERER_CAFILE
done