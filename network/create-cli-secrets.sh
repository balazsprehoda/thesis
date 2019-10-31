#!/bin/bash

kubectl create secret generic -n fabric-tools hlf--scripts --from-file=./cli-scripts

kubectl create secret generic -n fabric-tools hlf--chaincode --from-file=../src/chaincode/go