#!/bin/bash

CHAINCODE_NAME=go
CHAINCODE_VERSION=1.0
CHANNEL_NAME=mychannel
FABRIC_CFG_PATH=/etc/hyperledger/fabric
ORDERER_URL=ord1-hlf-ord.orderers.svc.cluster.local:7050
ORDERER_CAFILE=/fabric/config/crypto/ordererOrganizations/orderers.svc.cluster.local/orderers/ord1-hlf-ord.orderers.svc.cluster.local/tls/ca.crt

# Install chaincode
for ORG_NUM in $(seq 1 ${NUM_OF_ORGS})
do
    export CORE_PEER_LOCALMSPID=Org${ORG_NUM}MSP
    export CORE_PEER_MSPCONFIGPATH=/fabric/config/crypto/peerOrganizations/org${ORG_NUM}.svc.cluster.local/users/Admin@org${ORG_NUM}.svc.cluster.local/msp
    for PEER_NUM in $(seq 1 ${NUM_OF_PEERS})
    do
        export CORE_PEER_ADDRESS=peer${PEER_NUM}-hlf-peer.org${ORG_NUM}.svc.cluster.local:7051
        export CORE_PEER_TLS_ROOTCERT_FILE=/fabric/config/crypto/peerOrganizations/org${ORG_NUM}.svc.cluster.local/peers/peer${PEER_NUM}-hlf-peer.org${ORG_NUM}.svc.cluster.local/tls/ca.crt
        export CORE_PEER_TLS_CERT_FILE=/fabric/config/crypto/peerOrganizations/org${ORG_NUM}.svc.cluster.local/peers/peer${PEER_NUM}-hlf-peer.org${ORG_NUM}.svc.cluster.local/tls/server.crt
        export CORE_PEER_TLS_CLIENTCERT_FILE=$CORE_PEER_TLS_CERT_FILE
        export CORE_PEER_TLS_KEY_FILE=/fabric/config/crypto/peerOrganizations/org${ORG_NUM}.svc.cluster.local/peers/peer${PEER_NUM}-hlf-peer.org${ORG_NUM}.svc.cluster.local/tls/server.key
        export CORE_PEER_TLS_CLIENTKEY_FILE=$CORE_PEER_TLS_KEY_FILE

        peer chaincode install -n ${CHAINCODE_NAME} -v ${CHAINCODE_VERSION} -p github.com/chaincode/go
    done
done

# Create CC policy string
POLICY="'Org1MSP.member',"
for ORG_NUM in $(seq 1 ${NUM_OF_ORGS}-1)
do
    POLICY+="'Org${ORG_NUM}MSP.member,'"
done
POLICY+="'Org${NUM_OF_ORGS}MSP.member'"

export ORG_NUM=1
export PEER_NUM=1
export CORE_PEER_LOCALMSPID=Org${ORG_NUM}MSP
export CORE_PEER_MSPCONFIGPATH=/fabric/config/crypto/peerOrganizations/org${ORG_NUM}.svc.cluster.local/users/Admin@org${ORG_NUM}.svc.cluster.local/msp
export CORE_PEER_ADDRESS=peer${PEER_NUM}-hlf-peer.org${ORG_NUM}.svc.cluster.local:7051
export CORE_PEER_TLS_ROOTCERT_FILE=/fabric/config/crypto/peerOrganizations/org${ORG_NUM}.svc.cluster.local/peers/peer${PEER_NUM}-hlf-peer.org${ORG_NUM}.svc.cluster.local/tls/ca.crt

export CORE_PEER_TLS_CERT_FILE=/fabric/config/crypto/peerOrganizations/org${ORG_NUM}.svc.cluster.local/peers/peer${PEER_NUM}-hlf-peer.org${ORG_NUM}.svc.cluster.local/tls/server.crt
export CORE_PEER_TLS_CLIENTCERT_FILE=$CORE_PEER_TLS_CERT_FILE
export CORE_PEER_TLS_KEY_FILE=/fabric/config/crypto/peerOrganizations/org${ORG_NUM}.svc.cluster.local/peers/peer${PEER_NUM}-hlf-peer.org${ORG_NUM}.svc.cluster.local/tls/server.key
export CORE_PEER_TLS_CLIENTKEY_FILE=$CORE_PEER_TLS_KEY_FILE

peer chaincode instantiate -o ${ORDERER_URL} -C ${CHANNEL_NAME} -n ${CHAINCODE_NAME} -v ${CHAINCODE_VERSION} -P "AND(${POLICY})" -c '{"Args":["init"]}' --tls --cafile $ORDERER_CAFILE