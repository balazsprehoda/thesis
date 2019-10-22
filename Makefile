start:
	cd network && ../cryptogen generate --config=crypto-config.yaml
	cd network && ./rename-keys.sh

	kubectl create ns orderers
	kubectl create ns org1
	kubectl create ns org2
	kubectl create ns org3
	kubectl create ns fabric-tools

	@echo "-------Creating orderer secrets-------"
	cd network && ./create-orderer-admin-secrets.sh

	@echo "-------Creating peer secrets-------"
	cd network && ./create-peer-admin-secrets.sh

	@echo "-------Creating genesis and channel secrets-------"
	cd network && ./create-genesis-channel-secrets.sh

	@echo "-------Creating anchor peer configuration secrets-------"
	cd network && ./create-configtx.sh
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
	kubectl apply -f network/cli.yaml

	kubectl expose deployment -n org1 peer1-hlf-peer --name=peer1-service --type=NodePort

	make watch

join:
	cd network && ./fetch-join-channel.sh

destroy:
	rm -rf network/crypto-config/
	rm -rf network/channel-artifacts/
	helm del --purge ord1 cdb-peer1 cdb-peer2 cdb-peer3 peer1 peer2 peer3
	kubectl delete pod -n fabric-tools fabric-tools 
	kubectl delete ns orderers org1 org2 org3 fabric-tools
	kubectl delete secrets --all

watch:
	watch -n 2 'kubectl get pods --all-namespaces'