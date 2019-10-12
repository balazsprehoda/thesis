#!/bin/bash

helm install stable/hlf-peer -n peer0-org1 -f ./peer0org1_values.yaml
helm install stable/hlf-peer -n peer0-org2 -f ./peer0org2_values.yaml
helm install stable/hlf-peer -n peer0-org3 -f ./peer0org3_values.yaml
helm install stable/hlf-peer -n peer0-org4 -f ./peer0org4_values.yaml