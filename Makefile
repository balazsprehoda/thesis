SHELL := /bin/bash
NUMBER_OF_NODES?=40
NUMBER_OF_ORGS?=3
NUMBER_OF_ORDERERS?=3
NUMBER_OF_PEERS_PER_ORG?=1
NETWORK?=basic
CHANNEL_NAME?=mychannel
# Absolute path to project dir on host.
ABSPATH?=/home/prehi/thesis
# Absolute path to project dir on VM. Minikube mounts /home dir to /hosthome by default.
VM_ABSPATH?=/hosthome/prehi/thesis
# Fault injection target regex pattern and namespace
TARGET_PATTERN?=ord1-hlf
ACTION?=pause
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

	kubectl apply -f caliper/readpods.yaml
	kubectl apply -f caliper/rolebinding.yaml

	@echo "-------Deploying orderers-------"
	kubectl create -f network/orderers/

	@echo "-------Deploying peers and CouchDBs-------"
	kubectl create -f network/peers/

	@echo "-------Deploying cli-------"
	kubectl apply -f network/cli/cli.yaml
	

.PHONY: minikube
minikube:
	minikube start --kubernetes-version=1.15.4 --memory=4096

.PHONY: crypto-gen
crypto-gen:
	make crypto-del
	cd network && ../cryptogen generate --config=${NETWORK}/crypto-config.yaml
	cd scripts && NUMBER_OF_ORGS=${NUMBER_OF_ORGS} ./rename-keys.sh
	cd scripts && NUMBER_OF_ORGS=${NUMBER_OF_ORGS} NETWORK=${NETWORK} ./generate-artifacts.sh

.PHONY: generate
generate:
	# Generate network connection profile for external applications (Blockchain Analyzer)
	@cp templates/connection-profile-TEMPLATE.yaml network/connection-profile.yaml
	@sed -i -e "s~ABSPATH~${ABSPATH}~g" network/connection-profile.yaml

	# Generate orderer deployment config files
	@for ORD_NUM in $(shell seq 1 ${NUMBER_OF_ORDERERS}); \
	do \
		let NODE_NUM=$${ORD_NUM}%${NUMBER_OF_NODES}+1; \
		NODE_NAME=`printf "virt%02d" $$NODE_NUM`; \
		cp templates/orderer-TEMPLATE.yaml network/orderers/orderer$${ORD_NUM}.yaml; \
		sed -i -e  "s/ORD_NUMBER/$${ORD_NUM}/g" network/orderers/orderer$${ORD_NUM}.yaml; \
		sed -i -e  "s~ABSPATH~${VM_ABSPATH}~g" network/orderers/orderer$${ORD_NUM}.yaml; \
		sed -i -e  "s/NODE_NAME/$${NODE_NAME}/g" network/orderers/orderer$${ORD_NUM}.yaml; \
		cp templates/orderer-svc-TEMPLATE.yaml network/orderers/orderer$${ORD_NUM}_svc.yaml; \
		sed -i -e  "s/ORD_NUMBER/$${ORD_NUM}/g" network/orderers/orderer$${ORD_NUM}_svc.yaml; \
	done

	# Generate Caliper deployment config file
	@cp templates/caliper-TEMPLATE.yaml caliper/caliper.yaml
	@sed -i -e "s~ABSPATH~${VM_ABSPATH}~g" caliper/caliper.yaml

	# Generate CLI deployment config file
	@cp templates/cli-TEMPLATE.yaml network/cli/cli.yaml
	@sed -i -e "s~ABSPATH~${VM_ABSPATH}~g" network/cli/cli.yaml

	# Generate peer deployment config files
	@for ORG_NUM in $(shell seq 1 ${NUMBER_OF_ORGS}); \
	do \
		for PEER_NUM in $(shell seq 1 ${NUMBER_OF_PEERS_PER_ORG}); \
		do \
			let NODE_NUM="(($${ORG_NUM}-1)*${NUMBER_OF_PEERS_PER_ORG}+($${PEER_NUM}-1)+1)%${NUMBER_OF_NODES}+1"; \
			NODE_NAME=`printf "virt%02d" $$NODE_NUM`; \
			cp templates/peer-TEMPLATE.yaml network/peers/peer$${PEER_NUM}org$${ORG_NUM}.yaml; \
			sed -i -e "s/PEER_NAME/peer$${PEER_NUM}/g" network/peers/peer$${PEER_NUM}org$${ORG_NUM}.yaml; \
			sed -i -e "s/ORG_NAME/org$${ORG_NUM}/g" network/peers/peer$${PEER_NUM}org$${ORG_NUM}.yaml; \
			sed -i -e "s/MSP_NAME/Org$${ORG_NUM}MSP/g" network/peers/peer$${PEER_NUM}org$${ORG_NUM}.yaml; \
			sed -i -e "s~ABSPATH~${VM_ABSPATH}~g" network/peers/peer$${PEER_NUM}org$${ORG_NUM}.yaml; \
			sed -i -e "s/PEER_REQ_PORT/30$${ORG_NUM}51/g" network/peers/peer$${PEER_NUM}org$${ORG_NUM}.yaml; \
			sed -i -e "s/PEER_EVENT_PORT/30$${ORG_NUM}53/g" network/peers/peer$${PEER_NUM}org$${ORG_NUM}.yaml; \
			sed -i -e "s/NODE_NAME/$${NODE_NAME}/g" network/peers/peer$${PEER_NUM}org$${ORG_NUM}.yaml; \
			cp templates/peer-svc-TEMPLATE.yaml network/peers/peer$${PEER_NUM}org$${ORG_NUM}_svc.yaml; \
			sed -i -e "s/PEER_NAME/peer$${PEER_NUM}/g" network/peers/peer$${PEER_NUM}org$${ORG_NUM}_svc.yaml; \
			sed -i -e "s/ORG_NAME/org$${ORG_NUM}/g" network/peers/peer$${PEER_NUM}org$${ORG_NUM}_svc.yaml; \
			sed -i -e "s/PEER_REQ_PORT/30$${ORG_NUM}51/g" network/peers/peer$${PEER_NUM}org$${ORG_NUM}_svc.yaml; \
			sed -i -e "s/PEER_EVENT_PORT/30$${ORG_NUM}53/g" network/peers/peer$${PEER_NUM}org$${ORG_NUM}_svc.yaml; \
		done \
	done

.PHONY: expose
expose:
	for ORG_NUM in $(shell seq 1 ${NUMBER_OF_ORGS}); \
	do \
		for PEER_NUM in $(shell seq 1 ${NUMBER_OF_PEERS_PER_ORG}); \
		do \
			cp templates/peer-expose-TEMPLATE.yaml network/peers/peer$${PEER_NUM}org$${ORG_NUM}_expose.yaml; \
			sed -i -e "s/PEER_NAME/peer$${PEER_NUM}/g" network/peers/peer$${PEER_NUM}org$${ORG_NUM}_expose.yaml; \
			sed -i -e "s/ORG_NAME/org$${ORG_NUM}/g" network/peers/peer$${PEER_NUM}org$${ORG_NUM}_expose.yaml; \
			sed -i -e "s/PEER_REQ_PORT/30$${ORG_NUM}51/g" network/peers/peer$${PEER_NUM}org$${ORG_NUM}_expose.yaml; \
			sed -i -e "s/PEER_EVENT_PORT/30$${ORG_NUM}53/g" network/peers/peer$${PEER_NUM}org$${ORG_NUM}_expose.yaml; \
		done \
	done

.PHONY: pumba-generate
pumba-generate: export POD_NS=$(shell echo `./kubectl/kubectl get --no-headers=true pods --all-namespaces -o wide | grep ${TARGET_PATTERN} | awk -F " " '{out=$$1; print out}'`)
pumba-generate: export POD_NODE=$(shell echo `./kubectl/kubectl get --no-headers=true pods --all-namespaces -o wide | grep ${TARGET_PATTERN} | awk -F " " '{out=$$8; print out}'`)
pumba-generate:
	export TARGET_FILE=network/pumba/pumba-${ACTION}-${TARGET_PATTERN}.yaml; \
	cp templates/pumba-${ACTION}-TEMPLATE.yaml $${TARGET_FILE} && \
	sed -i -e "s/TARGET_NS/${POD_NS}/g" $${TARGET_FILE} && \
	sed -i -e "s/TARGET_NODE/${POD_NODE}/g" $${TARGET_FILE} && \
	sed -i -e "s/TARGET_PATTERN/${TARGET_PATTERN}/g" $${TARGET_FILE}

.PHONY: monitor
monitor:
	kubectl create ns monitoring
	kubectl create serviceaccount --namespace kube-system tiller
	kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
	kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'
	sleep 15
	helm install --name=main --namespace=monitoring stable/prometheus-operator -f helm/prometheus.yaml

.PHONY: pumba
pumba:
	kubectl create -f network/pumba/*

.PHONY: clean
clean:
	rm -rf network/orderers/*.yaml
	rm -rf network/peers/*.yaml
	rm -rf network/cli.yaml
	rm -rf network/connection-profile.yaml
	rm -rf caliper/caliper.yaml
	rm -rf network/pumba/*.yaml
	rm -rf network/channel-artifacts
	rm -rf network/crypto-config


.PHONY: join
join:
	kubectl exec -n fabric-tools fabric-tools -- bash -c "mkdir scripts && cp /fabric/config/scripts/* scripts/ && chmod +x scripts/* && NUM_OF_ORGS=${NUMBER_OF_ORGS} NUM_OF_PEERS=${NUMBER_OF_PEERS_PER_ORG} scripts/create-join-channel.sh"

.PHONY: chaincode
chaincode:
	kubectl exec -n fabric-tools fabric-tools -- bash -c "mkdir -p /opt/gopath/src/github.com/chaincode/go && cp /fabric/chaincode/* /opt/gopath/src/github.com/chaincode/go && cd /scripts && NUM_OF_ORGS=${NUMBER_OF_ORGS} NUM_OF_PEERS=${NUMBER_OF_PEERS_PER_ORG} ./install-instantiate-chaincode.sh"

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
	kubectl delete ns orderers fabric-tools caliper pumba monitoring
	for ORG_NUM in $(shell seq 1 ${NUMBER_OF_ORGS}); \
	do \
		kubectl delete ns org$${ORG_NUM}; \
	done
	kubectl delete customresourcedefinitions.apiextensions.k8s.io --all

.PHONY: crypto-del
crypto-del:
	rm -rf network/crypto-config/
	rm -rf network/channel-artifacts/

.PHONY: watch
watch:
	watch -n 2 'kubectl get pods --all-namespaces'

.PHONY: setup-32-ftsrglab
setup-32-ftsrglab:
	make generate NUMBER_OF_PEERS_PER_ORG=1 NUMBER_OF_ORGS=32 NUMBER_OF_ORDERERS=3 VM_ABSPATH=/home/meres/thesis ABSPATH=/home/meres/thesis
	make crypto-gen NETWORK=32-org NUMBER_OF_ORGS=32

.PHONY: setup-16-ftsrglab
setup-16-ftsrglab:
	make generate NUMBER_OF_PEERS_PER_ORG=2 NUMBER_OF_ORGS=16 NUMBER_OF_ORDERERS=3 VM_ABSPATH=/home/meres/thesis ABSPATH=/home/meres/thesis
	make crypto-gen NETWORK=16-org NUMBER_OF_ORGS=16

.PHONY: setup-8-ftsrglab
setup-8-ftsrglab:
	make generate NUMBER_OF_PEERS_PER_ORG=4 NUMBER_OF_ORGS=8 NUMBER_OF_ORDERERS=3 VM_ABSPATH=/home/meres/thesis ABSPATH=/home/meres/thesis
	make crypto-gen NETWORK=8-org NUMBER_OF_ORGS=8