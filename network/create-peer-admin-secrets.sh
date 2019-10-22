#!/bin/bash

for ORG_NUM in 1 2 3
do
    MSP_DIR=./crypto-config/peerOrganizations/org$ORG_NUM.svc.cluster.local/users/Admin@org$ORG_NUM.svc.cluster.local/msp

    ORG_CERT=$(ls ${MSP_DIR}/admincerts/*.pem)
    kubectl create secret generic -n org$ORG_NUM hlf--peer-admincert --from-file=cert.pem=$ORG_CERT

    ORG_KEY=$(ls ${MSP_DIR}/keystore/adminKey)
    kubectl create secret generic -n org$ORG_NUM hlf--peer-adminkey --from-file=key.pem=$ORG_KEY

    CA_CERT=$(ls ${MSP_DIR}/cacerts/*.pem)
    kubectl create secret generic -n org$ORG_NUM hlf--peer-cacert --from-file=cacert.pem=$CA_CERT

    kubectl create secret generic -n fabric-tools hlf--peer$ORG_NUM-admincert --from-file=cert.pem=$ORG_CERT
    kubectl create secret generic -n fabric-tools hlf--peer$ORG_NUM-adminkey --from-file=key.pem=$ORG_KEY
    kubectl create secret generic -n fabric-tools hlf--peer$ORG_NUM-cacert --from-file=cacert.pem=$CA_CERT
done
