#!/bin/bash

MSP_DIR=./crypto-config/ordererOrganizations/orderers.svc.cluster.local/orderers/ord1-hlf-ord.orderers.svc.cluster.local/msp

NODE_CERT=$(ls ${MSP_DIR}/signcerts/*.pem)
kubectl create secret generic -n orderers hlf--ord1-idcert --from-file=cert.pem=$NODE_CERT

NODE_KEY=$(ls ${MSP_DIR}/keystore/*_sk)
kubectl create secret generic -n orderers hlf--ord1-idkey --from-file=key.pem=$NODE_KEY


TLS_DIR=./crypto-config/ordererOrganizations/orderers.svc.cluster.local/orderers/ord1-hlf-ord.orderers.svc.cluster.local/tls

mv ${TLS_DIR}/server.crt ${TLS_DIR}/tls.crt
mv ${TLS_DIR}/server.key ${TLS_DIR}/tls.key

kubectl create secret generic -n orderers hlf--ord1-tls --from-file=$TLS_DIR

TLSCA_CERT=$(ls ${TLS_DIR}/ca.crt)
kubectl create secret generic -n orderers hlf--ord1-tls-rootcert --from-file=cacert.pem=$TLSCA_CERT
kubectl create secret generic -n org1 hlf--ord1-tls-rootcert --from-file=cacert.pem=$TLSCA_CERT
kubectl create secret generic -n org2 hlf--ord1-tls-rootcert --from-file=cacert.pem=$TLSCA_CERT
kubectl create secret generic -n org3 hlf--ord1-tls-rootcert --from-file=cacert.pem=$TLSCA_CERT
kubectl create secret generic -n fabric-tools hlf--ord1-tls-cacert --from-file=ca.crt=$TLSCA_CERT