NUMBER_OF_ORGS?=3
NUMBER_OF_ORDERERS?=3
NUMBER_OF_PEERS_PER_ORG?=1
CHANNEL_NAME?=mychannel
# Absolute path to project dir on host.
ABSPATH?=/home/prehi/thesis
# Absolute path to project dir on VM. Minikube mounts /home dir to /hosthome by default.
VM_ABSPATH?=/hosthome/prehi/thesis
# Fault injection target regex pattern and namespace
TARGET_PATTERN?=ord1-hlf
.PHONY: start
start:

	kubectl create ns orderers

	@for ORG_NUM in $(shell seq 1 ${NUMBER_OF_ORGS}); \
	do \
		kubectl create ns org$${ORG_NUM}; \
	done
	
	kubectl create ns fabric-tools
	kubectl create ns caliper
	kubectl create ns pumba

	@echo "-------Deploying orderers-------"
	@for ORD_NUM in $(shell seq 1 ${NUMBER_OF_ORDERERS}); \
	do \
		kubectl apply -f network/orderers/orderer$${ORD_NUM}.yaml; \
		kubectl apply -f network/orderers/orderer$${ORD_NUM}_svc.yaml; \
	done

	@echo "-------Deploying peers and CouchDBs-------"
	@for ORG_NUM in $(shell seq 1 ${NUMBER_OF_ORGS}); \
	do \
		for PEER_NUM in $(shell seq 1 ${NUMBER_OF_PEERS_PER_ORG}); \
		do \
			kubectl apply -f network/peers/peer$${ORG_NUM}.yaml; \
			kubectl apply -f network/peers/peer$${ORG_NUM}_svc.yaml; \
			kubectl apply -f network/peers/peer$${ORG_NUM}_expose.yaml; \
		done \
	done

	@echo "-------Deploying cli-------"
	kubectl apply -f network/cli.yaml

	@for PEER_NUM in $(shell seq 1 ${NUMBER_OF_ORGS}); \
	do \
		kubectl apply -f network/peer$${PEER_NUM}-exposed.yaml; \
	done
	

.PHONY: minikube
minikube:
	minikube start --kubernetes-version=1.15.4 --memory=4096

.PHONY: crypto-gen
crypto-gen:
	make crypto-del
	cd network && ../cryptogen generate --config=crypto-config.yaml
	cd network && ./rename-keys.sh
	cd network && ./generate-artifacts.sh

.PHONY: generate
generate:
	# Generate network connection profile for external applications (Blockchain Analyzer)
	cp templates/connection-profile-TEMPLATE.yaml network/connection-profile.yaml
	sed -i -e "s~ABSPATH~${ABSPATH}~g" network/connection-profile.yaml

	# Generate orderer deployment config files
	for ORD_NUM in $(shell seq 1 ${NUMBER_OF_ORDERERS}); \
	do \
		cp templates/orderer-TEMPLATE.yaml network/orderers/orderer$${ORD_NUM}.yaml; \
		sed -i -e  "s/ORD_NUMBER/$${ORD_NUM}/g" network/orderers/orderer$${ORD_NUM}.yaml; \
		sed -i -e  "s~ABSPATH~${VM_ABSPATH}~g" network/orderers/orderer$${ORD_NUM}.yaml; \
		cp templates/orderer-svc-TEMPLATE.yaml network/orderers/orderer$${ORD_NUM}_svc.yaml; \
		sed -i -e  "s/ORD_NUMBER/$${ORD_NUM}/g" network/orderers/orderer$${ORD_NUM}_svc.yaml; \
	done

	# Generate Caliper deployment config file
	cp templates/caliper-TEMPLATE.yaml caliper/caliper.yaml
	sed -i -e "s~ABSPATH~${VM_ABSPATH}~g" caliper/caliper.yaml

	# Generate CLI deployment config file
	cp templates/cli-TEMPLATE.yaml network/cli.yaml
	sed -i -e "s~ABSPATH~${VM_ABSPATH}~g" network/cli.yaml

	# Generate peer deployment config files
	for ORG_NUM in $(shell seq 1 ${NUMBER_OF_ORGS}); \
	do \
		for PEER_NUM in $(shell seq 1 ${NUMBER_OF_PEERS_PER_ORG}); \
		do \
			cp templates/peer-TEMPLATE.yaml network/peers/peer$${ORG_NUM}.yaml; \
			sed -i -e "s/PEER_NAME/peer$${ORG_NUM}/g" network/peers/peer$${ORG_NUM}.yaml; \
			sed -i -e "s/ORG_NAME/org$${ORG_NUM}/g" network/peers/peer$${ORG_NUM}.yaml; \
			sed -i -e "s/MSP_NAME/Org$${ORG_NUM}MSP/g" network/peers/peer$${ORG_NUM}.yaml; \
			sed -i -e "s~ABSPATH~${VM_ABSPATH}~g" network/peers/peer$${ORG_NUM}.yaml; \
			sed -i -e "s/PEER_REQ_PORT/30$${ORG_NUM}51/g" network/peers/peer$${ORG_NUM}.yaml; \
			sed -i -e "s/PEER_EVENT_PORT/30$${ORG_NUM}53/g" network/peers/peer$${ORG_NUM}.yaml; \
			cp templates/peer-svc-TEMPLATE.yaml network/peers/peer$${ORG_NUM}_svc.yaml; \
			sed -i -e "s/PEER_NAME/peer$${ORG_NUM}/g" network/peers/peer$${ORG_NUM}_svc.yaml; \
			sed -i -e "s/ORG_NAME/org$${ORG_NUM}/g" network/peers/peer$${ORG_NUM}_svc.yaml; \
			sed -i -e "s/PEER_REQ_PORT/30$${ORG_NUM}51/g" network/peers/peer$${ORG_NUM}_svc.yaml; \
			sed -i -e "s/PEER_EVENT_PORT/30$${ORG_NUM}53/g" network/peers/peer$${ORG_NUM}_svc.yaml; \
			cp templates/peer-expose-TEMPLATE.yaml network/peers/peer$${ORG_NUM}_expose.yaml; \
			sed -i -e "s/PEER_NAME/peer$${ORG_NUM}/g" network/peers/peer$${ORG_NUM}_expose.yaml; \
			sed -i -e "s/ORG_NAME/org$${ORG_NUM}/g" network/peers/peer$${ORG_NUM}_expose.yaml; \
			sed -i -e "s/PEER_REQ_PORT/30$${ORG_NUM}51/g" network/peers/peer$${ORG_NUM}_expose.yaml; \
			sed -i -e "s/PEER_EVENT_PORT/30$${ORG_NUM}53/g" network/peers/peer$${ORG_NUM}_expose.yaml; \
		done \
	done

.PHONY: pumba-generate
pumba-generate: export POD_NS=$(shell echo `kubectl get --no-headers=true pods --all-namespaces -o wide | grep $(shell echo `kubectl get pods -n ${TARGET_NS} --template='{{range.items}}{{.metadata.name}}{{printf "\n"}}{{end}}' | grep ${TARGET_PATTERN}`) | awk -F " " '{out=$$1; print out}'`)
pumba-generate: export POD_NODE=$(shell echo `kubectl get --no-headers=true pods -n ${POD_NS} -o wide | grep $(shell echo `kubectl get pods -n ${TARGET_NS} --template='{{range.items}}{{.metadata.name}}{{printf "\n"}}{{end}}' | grep ${TARGET_PATTERN}`) | awk -F " " '{out=$$7; print out}'`)
pumba-generate:
	export TARGET_FILE=network/pumba/pumba-kill-${TARGET_PATTERN}.yaml; \
	cp templates/pumba-kill-TEMPLATE.yaml $${TARGET_FILE} && \
	sed -i -e "s/TARGET_NS/${POD_NS}/g" $${TARGET_FILE} && \
	sed -i -e "s/TARGET_NODE/${POD_NODE}/g" $${TARGET_FILE} && \
	sed -i -e "s/TARGET_PATTERN/${TARGET_PATTERN}/g" $${TARGET_FILE}

.PHONY: clean
clean:
	rm -rf network/orderers/*.yaml
	rm -rf network/peers/*.yaml
	rm network/cli.yaml
	rm network/connection-profile.yaml
	rm caliper/caliper.yaml


.PHONY: join
join:
	kubectl exec -n fabric-tools fabric-tools -- bash -c "mkdir scripts && cp /fabric/config/scripts/* scripts/ && chmod +x scripts/* && scripts/create-join-channel.sh"

.PHONY: chaincode
chaincode:
	kubectl exec -n fabric-tools fabric-tools -- bash -c "mkdir -p /opt/gopath/src/github.com/chaincode/go && cp /fabric/chaincode/* /opt/gopath/src/github.com/chaincode/go && cd /scripts && ./install-instantiate-chaincode.sh"

.PHONY: init
init:
	kubectl exec -n fabric-tools fabric-tools -- bash -c "cd /scripts && ORG_NUM=${ORG_NUM} ./init-ledger.sh"

.PHONY: change-owner
change-owner:
	kubectl exec -n fabric-tools fabric-tools -- bash -c "cd /scripts && ORG_NUM=${ORG_NUM} ./change-owner.sh ${KEY} ${OWNER}"

.PHONY: caliper
caliper: caliper/caliper.yaml
	@echo "-------Deploying Caliper-------"
	kubectl apply -f caliper/caliper.yaml
	sleep 15
	kubectl logs -f -n caliper caliper

.PHONY: ord1-kill
ord1-kill:
	@echo "-------Deploying Pumba-------"
	kubectl create -f network/pumba_kill_ord1.yaml

.PHONY: net-delay
net-delay:
	@echo "-------Deploying Pumba-------"
	kubectl create -f network/pumba_network.yaml

.PHONY: destroy
destroy:
	kubectl delete ns orderers org1 org2 org3 fabric-tools caliper pumba

.PHONY: crypto-del
crypto-del:
	rm -rf network/crypto-config/
	rm -rf network/channel-artifacts/

.PHONY: watch
watch:
	watch -n 2 'kubectl get pods --all-namespaces'