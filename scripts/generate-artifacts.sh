#!/bin/bash

export CHANNEL_NAME=mychannel

mkdir ../network/channel-artifacts

../configtxgen -profile OrdererGenesis -outputBlock ../network/channel-artifacts/genesis.block -channelID syschannel -configPath ../network/${NETWORK}/

../configtxgen -profile TestChannel -channelID ${CHANNEL_NAME} -outputCreateChannelTx ../network/channel-artifacts/${CHANNEL_NAME}.tx -configPath ../network/${NETWORK}/

for ORG_NUM in $(seq 1 ${NUMBER_OF_ORGS})
do
    ../configtxgen -profile TestChannel -outputAnchorPeersUpdate ../network/channel-artifacts/Org${ORG_NUM}MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org${ORG_NUM}MSP -configPath ../network/${NETWORK}/
done
