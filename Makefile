NUMBER_OF_ORGS?=3

start:
	cd network && ../cryptogen generate --config=crypto-config.yaml
	cd network && ./rename-keys.sh

	kubectl create ns orderers

	for ORG_NUM in $(shell seq 1 ${NUMBER_OF_ORGS}); \
	do \
		kubectl create ns org$${ORG_NUM}; \
	done
	
	kubectl create ns fabric-tools
	kubectl create ns caliper
	kubectl create ns pumba

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
	for ORD_NUM in $(shell seq 1 ${NUMBER_OF_ORGS}); \
	do \
		kubectl apply -f network/orderer$${ORD_NUM}.yaml; \
		kubectl apply -f network/orderer$${ORD_NUM}_svc.yaml; \
	done

	@echo "-------Deploying CouchDBs-------"
	for ORG_NUM in $(shell seq 1 ${NUMBER_OF_ORGS}); \
	do \
		helm install stable/hlf-couchdb -n cdb-peer$${ORG_NUM} --namespace org$${ORG_NUM} -f ./helm/cdb_values.yaml; \
	done
	
	@echo "-------Creating peer node secrets-------"
	cd network && ./create-peer-node-secrets.sh

	@echo "-------Deploying peers-------"
	for ORG_NUM in $(shell seq 1 ${NUMBER_OF_ORGS}); \
	do \
		helm install stable/hlf-peer -n peer$${ORG_NUM} --namespace org$${ORG_NUM} -f ./helm/peer$${ORG_NUM}_values.yaml; \
	done

	@echo "-------Deploying cli-------"
	cd network && ./create-cli-secrets.sh
	kubectl apply -f network/cli.yaml

	for PEER_NUM in $(shell seq 1 ${NUMBER_OF_ORGS}); \
	do \
		kubectl apply -f network/peer$${PEER_NUM}-exposed.yaml; \
	done
	

	make watch

minikube:
	minikube start --kubernetes-version=1.15.4 --memory=4096

join:
	kubectl exec -n fabric-tools fabric-tools -- bash -c "mkdir scripts && cp /fabric/config/scripts/* scripts/ && chmod +x scripts/* && scripts/create-join-channel.sh"

chaincode:
	kubectl exec -n fabric-tools fabric-tools -- bash -c "mkdir -p /opt/gopath/src/github.com/chaincode/go && cp /fabric/chaincode/* /opt/gopath/src/github.com/chaincode/go && cd /opt/gopath/src/github.com/chaincode/go && go get github.com/hyperledger/fabric/core/chaincode && go build && cd /scripts && ./install-instantiate-chaincode.sh"

init:
	kubectl exec -n fabric-tools fabric-tools -- bash -c "cd /scripts && ORG_NUM=${ORG_NUM} ./init-ledger.sh"

change-owner:
	kubectl exec -n fabric-tools fabric-tools -- bash -c "cd /scripts && ORG_NUM=${ORG_NUM} ./change-owner.sh ${KEY} ${OWNER}"

.PHONY: caliper
caliper: caliper/caliper.yaml
	@echo "-------Deploying Caliper-------"
	kubectl apply -f caliper/caliper.yaml
	sleep 5
	kubectl logs -f -n caliper caliper

.PHONY: ord1-kill
ord1-kill:
	@echo "-------Deploying Pumba-------"
	kubectl create -f network/pumba_kill_ord1.yaml

.PHONY: net-delay
net-delay:
	@echo "-------Deploying Pumba-------"
	kubectl create -f network/pumba_network.yaml

destroy:
	rm -rf network/crypto-config/
	rm -rf network/channel-artifacts/
	kubectl delete ns orderers org1 org2 org3 fabric-tools caliper pumba
	helm del --purge cdb-peer1 cdb-peer2 cdb-peer3 peer1 peer2 peer3
	kubectl delete secrets --all

watch:
	watch -n 2 'kubectl get pods --all-namespaces'