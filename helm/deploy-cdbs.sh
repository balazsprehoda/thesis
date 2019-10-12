#!/bin/bash

helm install stable/hlf-couchdb -n cdb-peer0-org1 -f ./cdb_values.yaml
helm install stable/hlf-couchdb -n cdb-peer0-org2 -f ./cdb_values.yaml
helm install stable/hlf-couchdb -n cdb-peer0-org3 -f ./cdb_values.yaml
helm install stable/hlf-couchdb -n cdb-peer0-org4 -f ./cdb_values.yaml