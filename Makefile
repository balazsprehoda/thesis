start:
	make minikube-setup
	make generate-artifacts
	sleep 30
	make deploy

minikube-setup:
	minikube start --kubernetes-version=v1.15.4 --memory 4096
	helm init

generate-artifacts:
	make delete-artifacts
	cd network && ./generate-artifacts.sh
	cd network && ./create-secrets.sh

deploy:
	cd helm && ./deploy-cdbs.sh
	cd helm && ./deploy-orderers.sh
	cd helm && ./deploy-peers.sh

watch:
	watch -n 2 'kubectl get pods'

stop:
	helm delete peer0-org1 peer0-org2 peer0-org3 peer0-org4 orderer cdb-peer0-org1 cdb-peer0-org2 cdb-peer0-org3 cdb-peer0-org4

delete-artifacts:
	cd network && ./destroy-artifacts.sh
	kubectl delete secrets --all

destroy:
	make stop
	make delete-artifacts
	minikube delete