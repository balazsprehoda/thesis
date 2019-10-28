start:
	cd network && ../cryptogen generate --config=crypto-config.yaml
	cd network && ./rename-keys.sh

	kubectl create ns orderers
	kubectl create ns org1
	kubectl create ns org2
	kubectl create ns org3
	kubectl create ns fabric-tools
	kubectl create ns caliper

	@echo "-------Creating orderer secrets-------"
	cd network && ./create-orderer-admin-secrets.sh

	@echo "-------Creating peer secrets-------"
	cd network && ./create-peer-admin-secrets.sh

	@echo "-------Creating genesis and channel secrets-------"
	cd network && ./create-genesis-channel-secrets.sh

	@echo "-------Creating anchor peer configuration secrets-------"
	cd network && ./create-configtx-secrets.sh

	@echo "-------Creating orderer node secrets-------"
	cd network && ./create-orderer-node-secrets.sh

	@echo "-------Deploying orderers-------"
	helm install stable/hlf-ord -n ord1 --namespace orderers -f ./helm/ord1_values.yaml

	@echo "-------Deploying CouchDBs-------"
	helm install stable/hlf-couchdb -n cdb-peer1 --namespace org1 -f ./helm/cdb_values.yaml
	helm install stable/hlf-couchdb -n cdb-peer2 --namespace org2 -f ./helm/cdb_values.yaml
	helm install stable/hlf-couchdb -n cdb-peer3 --namespace org3 -f ./helm/cdb_values.yaml

	@echo "-------Creating peer node secrets-------"
	cd network && ./create-peer-node-secrets.sh

	@echo "-------Deploying peers-------"
	helm install stable/hlf-peer -n peer1 --namespace org1 -f ./helm/peer1_values.yaml
	helm install stable/hlf-peer -n peer2 --namespace org2 -f ./helm/peer2_values.yaml
	helm install stable/hlf-peer -n peer3 --namespace org3 -f ./helm/peer3_values.yaml

	@echo "-------Deploying cli-------"
	cd network && ./create-cli-secrets.sh
	kubectl apply -f network/cli.yaml

	kubectl apply -f network/peer1-exposed.yaml
	kubectl apply -f network/peer2-exposed.yaml
	kubectl apply -f network/peer3-exposed.yaml

	make watch

minikube:
	minikube start --kubernetes-version=1.15.4 --memory=4096 --mount-string="/home/prehi/thesis/caliper:/hlnetwork" --mount

join:
	kubectl exec -n fabric-tools fabric-tools -- bash -c "mkdir scripts && cp /fabric/config/scripts/* scripts/ && chmod +x scripts/* && scripts/create-join-channel.sh"

chaincode:
	kubectl exec -n fabric-tools fabric-tools -- bash -c "mkdir -p /opt/gopath/src/github.com/chaincode/go && cp /fabric/chaincode/* /opt/gopath/src/github.com/chaincode/go && cd /opt/gopath/src/github.com/chaincode/go && go get github.com/hyperledger/fabric/core/chaincode && go build && cd /scripts && ./install-instantiate-chaincode.sh"

init:
	kubectl exec -n fabric-tools fabric-tools -- bash -c "cd /scripts && ORG_NUM=${ORG_NUM} ./init-ledger.sh"

change-owner:
	kubectl exec -n fabric-tools fabric-tools -- bash -c "cd /scripts && ORG_NUM=${ORG_NUM} ./change-owner.sh ${KEY} ${OWNER}"

caliper:
	mkdir caliper/crypto-config
	mkdir caliper/channel-artifacts
	cp network/crypto-config/ caliper/crypto-config
	cp network/channel-artifacts/ caliper/channel-artifacts
	kubectl apply -f caliper/caliper.yaml

destroy:
	rm -rf network/crypto-config/
	rm -rf network/channel-artifacts/
	helm del --purge ord1 cdb-peer1 cdb-peer2 cdb-peer3 peer1 peer2 peer3
	kubectl delete pod -n fabric-tools fabric-tools
	kubectl delete pod -n caliper caliper
	kubectl delete ns orderers org1 org2 org3 fabric-tools caliper
	kubectl delete secrets --all

watch:
	watch -n 2 'kubectl get pods --all-namespaces'