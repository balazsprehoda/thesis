#!/bin/bash

mkdir ./crypto-config/tlsrootcerts

cp ./crypto-config/peerOrganizations/org1.svc.cluster.local/peers/peer1-hlf-peer.org1.svc.cluster.local/tls/ca.crt ./crypto-config/tlsrootcerts/ca1.crt
cp ./crypto-config/peerOrganizations/org2.svc.cluster.local/peers/peer2-hlf-peer.org2.svc.cluster.local/tls/ca.crt ./crypto-config/tlsrootcerts/ca2.crt
cp ./crypto-config/peerOrganizations/org3.svc.cluster.local/peers/peer3-hlf-peer.org3.svc.cluster.local/tls/ca.crt ./crypto-config/tlsrootcerts/ca3.crt

for ORG_NUM in 1 2 3
do
    MSP_DIR=./crypto-config/peerOrganizations/org$ORG_NUM.svc.cluster.local/peers/peer$ORG_NUM-hlf-peer.org$ORG_NUM.svc.cluster.local/msp

    NODE_CERT=$(ls ${MSP_DIR}/signcerts/*.pem)
    kubectl create secret generic -n org$ORG_NUM hlf--peer$ORG_NUM-idcert --from-file=cert.pem=$NODE_CERT

    NODE_KEY=$(ls ${MSP_DIR}/keystore/*_sk)
    kubectl create secret generic -n org$ORG_NUM hlf--peer$ORG_NUM-idkey --from-file=key.pem=$NODE_KEY

    TLS_DIR=./crypto-config/peerOrganizations/org$ORG_NUM.svc.cluster.local/peers/peer$ORG_NUM-hlf-peer.org$ORG_NUM.svc.cluster.local/tls

    mv ${TLS_DIR}/server.crt ${TLS_DIR}/tls.crt
    mv ${TLS_DIR}/server.key ${TLS_DIR}/tls.key

    kubectl create secret generic -n org$ORG_NUM hlf--peer$ORG_NUM-tls --from-file=$TLS_DIR
    kubectl create secret generic -n fabric-tools hlf--peer$ORG_NUM-tls --from-file=$TLS_DIR

    TLSCA_CERT=$(ls ${TLS_DIR}/ca.crt)
    kubectl create secret generic -n org$ORG_NUM hlf--peer$ORG_NUM-tls-rootcert --from-file=cacert.pem=$TLSCA_CERT
    kubectl create secret generic -n fabric-tools hlf--peer$ORG_NUM-tls-cacert --from-file=cacert.pem=$TLSCA_CERT

    kubectl create secret generic -n org$ORG_NUM hlf--peer$ORG_NUM-tls-clientrootcerts --from-file=./crypto-config/tlsrootcerts
done
