#!/bin/bash

export MSP_DIR=./crypto-config/ordererOrganizations/orderers.svc.cluster.local/users/Admin@orderers.svc.cluster.local/msp
export ORG_CERT=`ls ${MSP_DIR}/admincerts/*.pem`
export CA_CERT=`ls ${MSP_DIR}/cacerts/*.pem`

kubectl create secret generic -n orderers hlf--ord-admincert --from-file=cert.pem=$ORG_CERT
kubectl create secret generic -n orderers hlf--ord-cacert --from-file=cacert.pem=$CA_CERT