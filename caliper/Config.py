class Config(object):
    def __init__(self, **entries):
        self.__dict__.update(entries)
        self.name = "test-network"
        self.version = "1.0"
        self.caliper = {'blockchain': "fabric"}
        self.info = {'Version': '1.4.3', 'Size': '32 orgs with 1 peer each', 'Orderer': 'Raft with 3 orderers', 'Distribution': 'Kubernetes', 'StateDB': 'CouchDB'}
        self.clients = {}
        self.channels = {'mychannel': {'created': True, 'chaincodes': [{'id': 'go', 'version': "1.0", 'language': 'golang', 'path': 'chaincode/go'}], 'orderers': [], 'peers': {}}}
        self.orderers = {}
        self.peers = {}
        self.organizations = {}


    def add_client(self, org_number):
        client_name = 'client0.org' + str(org_number) + '.example.com'
        org_name = 'Org' + str(org_number)
        credentialStore = '/tmp/hfc-kvs/org' + str(org_number)
        cryptoStore = '/tmp/hfc-cvs/org' + str(org_number)
        clientPrivateKey = 'network/crypto-config/peerOrganizations/org' + str(org_number) + '.svc.cluster.local/users/User1@org' + str(org_number) + '.svc.cluster.local/msp/keystore/key.pem'
        clientSignedCert = 'network/crypto-config/peerOrganizations/org' + str(org_number) + '.svc.cluster.local/users/User1@org' + str(org_number) + '.svc.cluster.local/msp/signcerts/User1@org' + str(org_number) + '.svc.cluster.local-cert.pem'

        self.clients[client_name] = {
                'client': {
                    'organization': org_name, 'credentialStore': {
                        'path': credentialStore, 'cryptoStore': {
                            'path': cryptoStore,
                            }
                    },
                    'clientPrivateKey': {
                        'path': clientPrivateKey,
                    },
                    'clientSignedCert': {
                        'path': clientSignedCert,
                    },
                }
            }

    def add_orderer(self, orderer_number):
        orderer_name = 'ord' + str(orderer_number) + '-hlf-ord.orderers.svc.cluster.local'
        orderer_url = 'grpcs://' + orderer_name + ':7050'
        tls_ca_cert = 'network/crypto-config/ordererOrganizations/orderers.svc.cluster.local/orderers/' + orderer_name + '/msp/tlscacerts/tlsca.orderers.svc.cluster.local-cert.pem'
        self.channels['mychannel']['orderers'].append(orderer_name)
        self.orderers[orderer_name] = {'url': orderer_url, 'grpcOptions': {'ssl-target-name-override': orderer_name}, 'tlsCACerts': {'path': tls_ca_cert}}

    def add_peer(self, peer_number, org_number):
        peer_name = 'peer' + str(peer_number) + '-hlf-peer.org' + str(org_number) + '.svc.cluster.local'
        peer_url = 'grpcs://' + peer_name + ':7051'
        tls_ca_cert = 'network/crypto-config/peerOrganizations/org' + str(org_number) + '.svc.cluster.local/peers/' + peer_name + '/msp/tlscacerts/tlsca.org' + str(org_number) + '.svc.cluster.local-cert.pem'
        self.channels['mychannel']['peers'][peer_name] = {'eventSource': True}
        self.peers[peer_name] = {'url': peer_url, 'grpcOptions': {'ssl-target-name-override': peer_name}, 'tlsCACerts': {'path': tls_ca_cert}}
        org_name = 'Org' + str(org_number)
        self.organizations[org_name]['peers'].append(peer_name)

    def add_organization(self, org_number):
        org_name = 'Org' + str(org_number)
        msp_id = org_name + 'MSP'
        adminPrivateKey = 'network/crypto-config/peerOrganizations/org' + str(org_number) +'.svc.cluster.local/users/Admin@org' + str(org_number) + '.svc.cluster.local/msp/keystore/adminKey'
        signedCert = 'network/crypto-config/peerOrganizations/org' + str(org_number) + '.svc.cluster.local/users/Admin@org' + str(org_number) + '.svc.cluster.local/msp/signcerts/Admin@org' + str(org_number) + '.svc.cluster.local-cert.pem'
        self.organizations[org_name] = {
            'mspid': msp_id,
            'peers': [],
            'adminPrivateKey': {
                'path': adminPrivateKey,
            },
            'signedCert': {
                'path': signedCert,
            },
        }

