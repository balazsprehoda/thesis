#!/bin/bash

CHAINCODE_NAME=go
CHAINCODE_VERSION=1.0
CHANNEL_NAME=mychannel
FABRIC_CFG_PATH=/etc/hyperledger/fabric
ORDERER_URL=ord1-hlf-ord.orderers.svc.cluster.local:7050
ORDERER_CAFILE=/fabric/config/crypto/ordererOrganizations/orderers.svc.cluster.local/orderers/ord1-hlf-ord.orderers.svc.cluster.local/tls/ca.crt

if [ -z "$ORG_NUM" ]
then
    export ORG_NUM=1
fi

export CORE_PEER_LOCALMSPID=Org${ORG_NUM}MSP
export CORE_PEER_MSPCONFIGPATH=/fabric/config/crypto/peerOrganizations/org${ORG_NUM}.svc.cluster.local/users/Admin@org${ORG_NUM}.svc.cluster.local/msp
export CORE_PEER_ADDRESS=peer${ORG_NUM}-hlf-peer.org${ORG_NUM}.svc.cluster.local:7051
export CORE_PEER_TLS_ROOTCERT_FILE=/fabric/config/crypto/peerOrganizations/org${ORG_NUM}.svc.cluster.local/peers/peer${ORG_NUM}-hlf-peer.org${ORG_NUM}.svc.cluster.local/tls/ca.crt
export CORE_PEER_TLS_CLIENTROOTCAS_FILES="/fabric/config/crypto/tlsrootcerts/ca1.crt /fabric/config/crypto/tlsrootcerts/ca2.crt /fabric/config/crypto/tlsrootcerts/ca3.crt"
export CORE_PEER_TLS_CERT_FILE=/fabric/config/crypto/peerOrganizations/org${ORG_NUM}.svc.cluster.local/peers/peer${ORG_NUM}-hlf-peer.org${ORG_NUM}.svc.cluster.local/tls/tls.crt
export CORE_PEER_TLS_CLIENTCERT_FILE=$CORE_PEER_TLS_CERT_FILE
export CORE_PEER_TLS_KEY_FILE=/fabric/config/crypto/peerOrganizations/org${ORG_NUM}.svc.cluster.local/peers/peer${ORG_NUM}-hlf-peer.org${ORG_NUM}.svc.cluster.local/tls/tls.key
export CORE_PEER_TLS_CLIENTKEY_FILE=$CORE_PEER_TLS_KEY_FILE

peer chaincode invoke -o ${ORDERER_URL} -C ${CHANNEL_NAME} -n ${CHAINCODE_NAME} -c "{\"Args\":[\"initLedger\"]}" --tls --cafile $ORDERER_CAFILE