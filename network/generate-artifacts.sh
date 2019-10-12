#!/bin/bash

export GOPATH=$HOME/go
export GOBIN=$GOPATH/bin
export PATH=$PATH:$GOBIN
export FABRIC_CFG_PATH=$PWD

CRYPTOGEN=../cryptogen
CONFIGTXGEN=../configtxgen

WHICHOS=`uname -a`;
OSTYPE="Linux"
echo $WHICHOS
if [[  "${WHICHOS}" == *"Darwin"* ]]; then
  OSTYPE="Darwin"
fi

if [[ ${OSTYPE} == "Darwin" ]]; then
  CRYPTOGEN=../cryptogen_mac
  CONFIGTXGEN=../configtxgen_mac
fi

#Generate crypto material using crypto-config.yaml as config file
${CRYPTOGEN} generate --config=./crypto-config.yaml

#Rename admin, ca and peer private key and cert files (needed for secrets)
for ORG_NUM in 1 2 3 4
do
	mv ./crypto-config/peerOrganizations/org$ORG_NUM/users/Admin@org$ORG_NUM/msp/keystore/*_sk ./crypto-config/peerOrganizations/org$ORG_NUM/users/Admin@org$ORG_NUM/msp/keystore/key.pem
  mv ./crypto-config/peerOrganizations/org$ORG_NUM/ca/*_sk ./crypto-config/peerOrganizations/org$ORG_NUM/ca/key.pem
  mv ./crypto-config/peerOrganizations/org$ORG_NUM/peers/peer0.org$ORG_NUM/msp/keystore/*_sk ./crypto-config/peerOrganizations/org$ORG_NUM/peers/peer0.org$ORG_NUM/msp/keystore/key.pem

  mv ./crypto-config/peerOrganizations/org$ORG_NUM/users/Admin@org$ORG_NUM/msp/signcerts/*.pem ./crypto-config/peerOrganizations/org$ORG_NUM/users/Admin@org$ORG_NUM/msp/signcerts/cert.pem
  mv ./crypto-config/peerOrganizations/org$ORG_NUM/ca/*-cert.pem ./crypto-config/peerOrganizations/org$ORG_NUM/ca/cacert.pem
  mv ./crypto-config/peerOrganizations/org$ORG_NUM/peers/peer0.org$ORG_NUM/msp/signcerts/*-cert.pem ./crypto-config/peerOrganizations/org$ORG_NUM/peers/peer0.org$ORG_NUM/msp/signcerts/cert.pem
done
mv ./crypto-config/ordererOrganizations/ordererorg/ca/*_sk ./crypto-config/ordererOrganizations/ordererorg/ca/key.pem
mv ./crypto-config/ordererOrganizations/ordererorg/ca/*-cert.pem ./crypto-config/ordererOrganizations/ordererorg/ca/cacert.pem
mv ./crypto-config/ordererOrganizations/ordererorg/orderers/orderer.ordererorg/msp/keystore/*_sk ./crypto-config/ordererOrganizations/ordererorg/orderers/orderer.ordererorg/msp/keystore/key.pem
mv ./crypto-config/ordererOrganizations/ordererorg/orderers/orderer.ordererorg/msp/signcerts/*-cert.pem ./crypto-config/ordererOrganizations/ordererorg/orderers/orderer.ordererorg/msp/signcerts/cert.pem
mv ./crypto-config/ordererOrganizations/ordererorg/orderers/orderer.ordererorg/msp/admincerts/*-cert.pem ./crypto-config/ordererOrganizations/ordererorg/orderers/orderer.ordererorg/msp/admincerts/admincert.pem
mv ./crypto-config/ordererOrganizations/ordererorg/tlsca/tlsca.ordererorg-cert.pem ./crypto-config/ordererOrganizations/ordererorg/tlsca/cacert.pem
mv ./crypto-config/ordererOrganizations/ordererorg/orderers/orderer.ordererorg/tls/server.crt ./crypto-config/ordererOrganizations/ordererorg/orderers/orderer.ordererorg/tls/tls.crt
mv ./crypto-config/ordererOrganizations/ordererorg/orderers/orderer.ordererorg/tls/server.key ./crypto-config/ordererOrganizations/ordererorg/orderers/orderer.ordererorg/tls/tls.key
mv ./crypto-config/ordererOrganizations/ordererorg/orderers/orderer.ordererorg/tls/ca.crt ./crypto-config/ordererOrganizations/ordererorg/orderers/orderer.ordererorg/tls/cacert.pem

#Generate configuration txs
mkdir channel-artifacts
${CONFIGTXGEN} -profile FourOrgsOrdererGenesis -outputBlock ./channel-artifacts/genesis.block
export CHANNEL_NAME=mychannel
${CONFIGTXGEN} -profile FourOrgsChannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID $CHANNEL_NAME

${CONFIGTXGEN} -profile FourOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org1MSP
${CONFIGTXGEN} -profile FourOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org2MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org2MSP
${CONFIGTXGEN} -profile FourOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org3MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org3MSP
${CONFIGTXGEN} -profile FourOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org4MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org4MSP
