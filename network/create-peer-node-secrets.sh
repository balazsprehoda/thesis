#!/bin/bash

for ORG_NUM in 1 2 3
do
    MSP_DIR=./crypto-config/peerOrganizations/org$ORG_NUM.svc.cluster.local/peers/peer$ORG_NUM-hlf-peer.org$ORG_NUM.svc.cluster.local/msp

    NODE_CERT=$(ls ${MSP_DIR}/signcerts/*.pem)
    kubectl create secret generic -n org$ORG_NUM hlf--peer$ORG_NUM-idcert --from-file=cert.pem=$NODE_CERT

    NODE_KEY=$(ls ${MSP_DIR}/keystore/*_sk)
    kubectl create secret generic -n org$ORG_NUM hlf--peer$ORG_NUM-idkey --from-file=key.pem=$NODE_KEY
done
