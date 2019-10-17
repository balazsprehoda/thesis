#!/bin/bash

helm install stable/hlf-peer -n peer1 -f ./peer0org1_values.yaml
helm install stable/hlf-peer -n peer2 -f ./peer0org2_values.yaml
helm install stable/hlf-peer -n peer3 -f ./peer0org3_values.yaml