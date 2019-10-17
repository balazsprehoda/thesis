#!/bin/bash

MSP_DIR=./crypto-config/ordererOrganizations/orderers.svc.cluster.local/orderers/ord1-hlf-ord.orderers.svc.cluster.local/msp

NODE_CERT=$(ls ${MSP_DIR}/signcerts/*.pem)
kubectl create secret generic -n orderers hlf--ord1-idcert --from-file=cert.pem=$NODE_CERT

NODE_KEY=$(ls ${MSP_DIR}/keystore/*_sk)
kubectl create secret generic -n orderers hlf--ord1-idkey --from-file=key.pem=$NODE_KEY