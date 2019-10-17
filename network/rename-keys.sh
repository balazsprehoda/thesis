#!/bin/bash
for ORG_NUM in 1 2 3
do
    mv ./crypto-config/peerOrganizations/org$ORG_NUM.svc.cluster.local/users/Admin@org$ORG_NUM.svc.cluster.local/msp/keystore/*_sk ./crypto-config/peerOrganizations/org$ORG_NUM.svc.cluster.local/users/Admin@org$ORG_NUM.svc.cluster.local/msp/keystore/adminKey
done