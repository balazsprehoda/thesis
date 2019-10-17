#!/bin/bash

mkdir channel-artifacts

../configtxgen -profile OrdererGenesis -outputBlock ./channel-artifacts/genesis.block

../configtxgen -profile ThreeOrgsChannel -channelID mychannel -outputCreateChannelTx ./channel-artifacts/mychannel.tx

kubectl create secret generic -n orderers hlf--genesis --from-file=./channel-artifacts/genesis.block

kubectl create secret generic -n org1 hlf--channel --from-file=./channel-artifacts/mychannel.tx
kubectl create secret generic -n org2 hlf--channel --from-file=./channel-artifacts/mychannel.tx
kubectl create secret generic -n org3 hlf--channel --from-file=./channel-artifacts/mychannel.tx