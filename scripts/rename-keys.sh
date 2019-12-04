#!/bin/bash
for ORG_NUM in $(seq 1 ${NUMBER_OF_ORGS})
do
    mv ../network/crypto-config/peerOrganizations/org$ORG_NUM.svc.cluster.local/users/Admin@org$ORG_NUM.svc.cluster.local/msp/keystore/*_sk ../network/crypto-config/peerOrganizations/org$ORG_NUM.svc.cluster.local/users/Admin@org$ORG_NUM.svc.cluster.local/msp/keystore/adminKey
    mv ../network/crypto-config/peerOrganizations/org$ORG_NUM.svc.cluster.local/users/User1@org$ORG_NUM.svc.cluster.local/msp/keystore/*_sk ../network/crypto-config/peerOrganizations/org$ORG_NUM.svc.cluster.local/users/User1@org$ORG_NUM.svc.cluster.local/msp/keystore/key.pem
done