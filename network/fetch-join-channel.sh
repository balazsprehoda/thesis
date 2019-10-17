#!/bin/bash

PEER_POD=$(kubectl get pods -n org1 -l "app=hlf-peer,release=peer1" -o jsonpath="{.items[0].metadata.name}")
kubectl exec -n org1 $PEER_POD -- peer channel create -o ord1-hlf-ord.orderers.svc.cluster.local:7050 -c mychannel -f /hl_config/channel/hlf--channel/mychannel.tx

for ORG_NUM in 1 2 3
do
    PEER_POD=$(kubectl get pods -n org${ORG_NUM} -l "app=hlf-peer,release=peer${ORG_NUM}" -o jsonpath="{.items[0].metadata.name}")

    kubectl exec -n org${ORG_NUM} $PEER_POD -- peer channel fetch config /var/hyperledger/mychannel.block -c mychannel -o ord1-hlf-ord.orderers.svc.cluster.local:7050

    kubectl exec -n org${ORG_NUM} $PEER_POD -- bash -c 'CORE_PEER_MSPCONFIGPATH=$ADMIN_MSP_PATH peer channel join -b /var/hyperledger/mychannel.block'
done
