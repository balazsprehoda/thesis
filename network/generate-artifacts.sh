#!/bin/bash

export CHANNEL_NAME=mychannel

mkdir channel-artifacts

../configtxgen -profile OrdererGenesis -outputBlock ./channel-artifacts/genesis.block -channelID syschannel -configPath ${NETWORK}/configtx.yaml

../configtxgen -profile TestChannel -channelID ${CHANNEL_NAME} -outputCreateChannelTx ./channel-artifacts/${CHANNEL_NAME}.tx

for ORG_NUM in $(shell seq 1 ${NUMBER_OF_ORGS})
do
    ../configtxgen -profile TestChannel -outputAnchorPeersUpdate ./channel-artifacts/Org${ORG_NUM}MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org${ORG_NUM}MSP
done
