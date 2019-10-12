#!/bin/bash

#Make secrets for orderer

kubectl create secret generic orderer-cert --from-file=./crypto-config/ordererOrganizations/ordererorg/orderers/orderer.ordererorg/msp/signcerts/cert.pem
kubectl create secret generic orderer-key --from-file=./crypto-config/ordererOrganizations/ordererorg/orderers/orderer.ordererorg/msp/keystore/key.pem
kubectl create secret generic orderer-cacert --from-file=./crypto-config/ordererOrganizations/ordererorg/ca/cacert.pem
kubectl create secret generic orderer-admincert --from-file=./crypto-config/ordererOrganizations/ordererorg/orderers/orderer.ordererorg/msp/admincerts/admincert.pem
kubectl create secret generic orderer-genesis --from-file=./channel-artifacts/genesis.block

kubectl create secret generic channel --from-file=./channel-artifacts/channel.tx

kubectl create secret generic tls-ca --from-file=./crypto-config/ordererOrganizations/ordererorg/tlsca/cacert.pem

kubectl create secret generic orderer-tls --from-file=./crypto-config/ordererOrganizations/ordererorg/orderers/orderer.ordererorg/tls
kubectl create secret generic orderer-tls-rootcert --from-file=./crypto-config/ordererOrganizations/ordererorg/orderers/orderer.ordererorg/tls/cacert.pem

#Make secrets for peers

for ORG_NUM in 1 2 3 4
do
    #Peer certs
    kubectl create secret generic peer0org$ORG_NUM-idcert --from-file=./crypto-config/peerOrganizations/org$ORG_NUM/peers/peer0.org$ORG_NUM/msp/signcerts/cert.pem
    #Peer private keys
    kubectl create secret generic peer0org$ORG_NUM-idkey --from-file=./crypto-config/peerOrganizations/org$ORG_NUM/peers/peer0.org$ORG_NUM/msp/keystore/key.pem
    #Organization admin certs
    kubectl create secret generic org$ORG_NUM-admincert --from-file=./crypto-config/peerOrganizations/org$ORG_NUM/users/Admin@org$ORG_NUM/msp/signcerts/cert.pem
    #Organization admin keys
    kubectl create secret generic org$ORG_NUM-adminkey --from-file=./crypto-config/peerOrganizations/org$ORG_NUM/users/Admin@org$ORG_NUM/msp/keystore/key.pem
    #Organization CA certs
    kubectl create secret generic org$ORG_NUM-cacert --from-file=./crypto-config/peerOrganizations/org$ORG_NUM/ca/cacert.pem
done