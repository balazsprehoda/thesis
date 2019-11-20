#!/bin/bash

export CHANNEL_NAME=mychannel

mkdir channel-artifacts

../configtxgen -profile OrdererGenesis -outputBlock ./channel-artifacts/genesis.block -channelID syschannel

../configtxgen -profile ThreeOrgsChannel -channelID ${CHANNEL_NAME} -outputCreateChannelTx ./channel-artifacts/${CHANNEL_NAME}.tx

../configtxgen -profile ThreeOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org1MSP
../configtxgen -profile ThreeOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org2MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org2MSP
../configtxgen -profile ThreeOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org3MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org3MSP