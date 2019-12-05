#!/bin/bash

export CHANNEL_NAME=mychannel
export ORDERER_URL=ord1-hlf-ord.orderers.svc.cluster.local:7050
export CORE_PEER_LOCALMSPID=Org1MSP
export CORE_PEER_MSPCONFIGPATH=/fabric/config/crypto/peerOrganizations/org1.svc.cluster.local/users/Admin@org1.svc.cluster.local/msp
export CORE_PEER_ADDRESS=peer1-hlf-peer.org1.svc.cluster.local:30151
export FABRIC_CFG_PATH=/etc/hyperledger/fabric
export ORDERER_CAFILE=/fabric/config/crypto/ordererOrganizations/orderers.svc.cluster.local/orderers/ord1-hlf-ord.orderers.svc.cluster.local/tls/ca.crt
export CORE_PEER_TLS_ROOTCERT_FILE=/fabric/config/crypto/peerOrganizations/org1.svc.cluster.local/peers/peer1-hlf-peer.org1.svc.cluster.local/tls/ca.crt

# Create channel
peer channel create -o ${ORDERER_URL} -c ${CHANNEL_NAME} -f /fabric/config/channel-artifacts/mychannel.tx --tls --cafile $ORDERER_CAFILE
echo "################# CHANNEL CREATED #################"

# Join peers
for ORG_NUM in $(seq 1 ${NUM_OF_ORGS})
do
    export CORE_PEER_MSPCONFIGPATH=/fabric/config/crypto/peerOrganizations/org${ORG_NUM}.svc.cluster.local/users/Admin@org${ORG_NUM}.svc.cluster.local/msp
    export CORE_PEER_LOCALMSPID=Org${ORG_NUM}MSP
    for PEER_NUM in $(seq 1 ${NUM_OF_PEERS})
    do
        export CORE_PEER_ADDRESS=peer${PEER_NUM}-hlf-peer.org${ORG_NUM}.svc.cluster.local:7051
        export CORE_PEER_TLS_ROOTCERT_FILE=/fabric/config/crypto/peerOrganizations/org${ORG_NUM}.svc.cluster.local/peers/peer${PEER_NUM}-hlf-peer.org${ORG_NUM}.svc.cluster.local/tls/ca.crt
        export CORE_PEER_TLS_CERT_FILE=/fabric/config/crypto/peerOrganizations/org${ORG_NUM}.svc.cluster.local/peers/peer${PEER_NUM}-hlf-peer.org${ORG_NUM}.svc.cluster.local/tls/server.crt
        export CORE_PEER_TLS_CLIENTCERT_FILE=$CORE_PEER_TLS_CERT_FILE
        export CORE_PEER_TLS_KEY_FILE=/fabric/config/crypto/peerOrganizations/org${ORG_NUM}.svc.cluster.local/peers/peer${PEER_NUM}-hlf-peer.org${ORG_NUM}.svc.cluster.local/tls/server.key
        export CORE_PEER_TLS_CLIENTKEY_FILE=$CORE_PEER_TLS_KEY_FILE

        peer channel join -b ${CHANNEL_NAME}.block
    done
done

# Update anchor peers
for ORG_NUM in $(seq 1 ${NUM_OF_ORGS})
do
    export CORE_PEER_LOCALMSPID=Org${ORG_NUM}MSP
    export CORE_PEER_MSPCONFIGPATH=/fabric/config/crypto/peerOrganizations/org${ORG_NUM}.svc.cluster.local/peers/peer1-hlf-peer.org${ORG_NUM}.svc.cluster.local/msp
    export CORE_PEER_ADDRESS=peer${ORG_NUM}-hlf-peer.org${ORG_NUM}.svc.cluster.local:7051
    export CORE_PEER_TLS_ROOTCERT_FILE=/fabric/config/crypto/peerOrganizations/org${ORG_NUM}.svc.cluster.local/peers/peer1-hlf-peer.org${ORG_NUM}.svc.cluster.local/tls/ca.crt

    peer channel update -o ${ORDERER_URL} -c ${CHANNEL_NAME} -f /fabric/config/channel-artifacts/Org${ORG_NUM}MSPanchors.tx --tls --cafile $ORDERER_CAFILE
done