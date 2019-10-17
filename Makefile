start:
	cd network && ../cryptogen generate --config=crypto-config.yaml
	cd network && ./rename-keys.sh

	kubectl create ns orderers
	kubectl create ns org1
	kubectl create ns org2
	kubectl create ns org3

	@echo "-------Creating orderer secrets-------"
	cd network && ./create-orderer-admin-secrets.sh

	@echo "-------Creating peer secrets-------"
	cd network && ./create-peer-admin-secrets.sh

	@echo "-------Creating genesis and channel secrets-------"
	cd network && ./create-genesis-channel-secrets.sh

	@echo "-------Creating anchor peer configuration secrets-------"
	cd network && ./create-config-txs.sh

	@echo "-------Creating orderer node secrets-------"
	cd network && ./create-orderer-node-secrets.sh

	@echo "-------Deploying orderers-------"
	helm install stable/hlf-ord -n ord1 --namespace orderers -f ./helm/ord1_values.yaml

	@echo "-------Deploying CouchDB for peer1-------"
	helm install stable/hlf-couchdb -n cdb-peer1 --namespace org1 -f ./helm/cdb_values.yaml
	helm install stable/hlf-couchdb -n cdb-peer2 --namespace org2 -f ./helm/cdb_values.yaml
	helm install stable/hlf-couchdb -n cdb-peer3 --namespace org3 -f ./helm/cdb_values.yaml

	@echo "-------Creating peer node secrets-------"
	cd network && ./create-peer-node-secrets.sh

	@echo "-------Deploying peers-------"
	helm install stable/hlf-peer -n peer1 --namespace org1 -f ./helm/peer1_values.yaml
	helm install stable/hlf-peer -n peer2 --namespace org2 -f ./helm/peer2_values.yaml
	helm install stable/hlf-peer -n peer3 --namespace org3 -f ./helm/peer3_values.yaml

	@echo "-------Deploying ingress controller (nginx)-------"
	helm install stable/nginx-ingress --name my-nginx

	make watch

join:
	cd network && ./fetch-join-channel.sh

destroy:
	rm -rf network/crypto-config/
	rm -rf network/channel-artifacts/
	kubectl delete ns orderers org1 org2 org3
	helm del --purge ord1 cdb-peer1 cdb-peer2 cdb-peer3 peer1 peer2 peer3 my-nginx
	kubectl delete secrets --all

watch:
	watch -n 2 'kubectl get pods --all-namespaces'

channel-create:
	PEER_POD=$(echo $(kubectl get pods -n peers -l "app=hlf-peer,release=peer1" -o jsonpath="{.items[0].metadata.name}"))