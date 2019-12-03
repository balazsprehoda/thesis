class Cryptoconfig(object):
    def __init__(self, **entries):
        self.__dict__.update(entries)
        self.OrdererOrgs = [{
            'Name': 'OrdererOrg',
            'Domain': 'orderers.svc.cluster.local',
            'Specs': [],
        }]
        self.PeerOrgs = []

    def add_orderer(self, ord_number):
        ord_name = 'ord' + str(ord_number) + '-hlf-ord'
        self.OrdererOrgs[0]['Specs'].append({
            'Hostname': ord_name,
        })
    
    def add_peer_org(self, org_number):
        org_name = 'Org' + str(org_number)
        domain_name = 'org' + str(org_number) + '.svc.cluster.local'
        self.PeerOrgs.append({
            'Name': org_name,
            'Domain': domain_name,
            'Users': {
                'Count': 1
            },
            'Specs': [],
        })

    def add_peer(self, peer_number, org_number):
        peer_name = 'peer' + str(peer_number) + '-hlf-peer'
        self.PeerOrgs[org_number - 1]['Specs'].append({
            'Hostname': peer_name,
        })