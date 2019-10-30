#!/bin/bash

CHANNEL_NAME=mychannel

mkdir channel-artifacts

../configtxgen -profile OrdererGenesis -outputBlock ./channel-artifacts/genesis.block -channelID syschannel

../configtxgen -profile ThreeOrgsChannel -channelID ${CHANNEL_NAME} -outputCreateChannelTx ./channel-artifacts/${CHANNEL_NAME}.tx

kubectl create secret generic -n orderers hlf--genesis --from-file=./channel-artifacts/genesis.block

kubectl create secret generic -n org1 hlf--channel --from-file=./channel-artifacts/${CHANNEL_NAME}.tx
kubectl create secret generic -n org2 hlf--channel --from-file=./channel-artifacts/${CHANNEL_NAME}.tx
kubectl create secret generic -n org3 hlf--channel --from-file=./channel-artifacts/${CHANNEL_NAME}.tx