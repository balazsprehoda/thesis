class Txconfig(object):
    def __init__(self, **entries):
        self.__dict__.update(entries)
        self.Organizations = [{
                'Name': 'OrdererOrg',
                'ID': 'OrdererMSP',
                'MSPDir': '../crypto-config/ordererOrganizations/orderers.svc.cluster.local/msp',
                'Policies': {
                    'Readers': {
                        'Type': 'ImplicitMeta',
                        'Rule': "ANY Readers",
                    },
                    'Writers': {
                        'Type': 'ImplicitMeta',
                        'Rule': "ANY Writers",
                    },
                    'Admins': {
                        'Type': 'ImplicitMeta',
                        'Rule': "MAJORITY Admins",
                    },
                },
            }]
        self.Orderer = {
            'OrdererType': 'etcdraft',
            'Addresses': [],
            'BatchTimeout': '2s',
            'BatchSize': {
                'MaxMessageCount': 40,
                'AbsoluteMaxBytes': '500MB',
                'PreferredMaxBytes': '500MB'
            },
            'EtcdRaft': {
                'Consenters': [],
            },
            'Organizations': self.Organizations[0],
            'Policies': {
                'Readers': {
                    'Type': 'ImplicitMeta',
                    'Rule': "ANY Readers",
                },
                'Writers': {
                    'Type': 'ImplicitMeta',
                    'Rule': "ANY Writers",
                },
                'Admins': {
                    'Type': 'ImplicitMeta',
                    'Rule': "MAJORITY Admins",
                },
                'BlockValidation': {
                    'Type': 'ImplicitMeta',
                    'Rule': "ANY Writers",
                }
            }
        }
        self.Capabilities = {
            'Channel': {
                'V1_3': True,
            },
            'Orderer': {
                'V1_1': True,
            },
            'Application': {
                'V1_3': True,
                'V1_2': False,
                'V1_1': False,
            },
        }
        self.Application = {
            'Policies': {
                'Readers': {
                    'Type': 'ImplicitMeta',
                    'Rule': "ANY Readers",
                },
                'Writers': {
                    'Type': 'ImplicitMeta',
                    'Rule': "ANY Writers",
                },
                'Admins': {
                    'Type': 'ImplicitMeta',
                    'Rule': "MAJORITY Admins",
                },
            },
            'Capabilities': self.Capabilities['Application'],
        }
        self.Channel = {
            'Policies': {
                'Readers': {
                    'Type': 'ImplicitMeta',
                    'Rule': "ANY Readers",
                },
                'Writers': {
                    'Type': 'ImplicitMeta',
                    'Rule': "ANY Writers",
                },
                'Admins': {
                    'Type': 'ImplicitMeta',
                    'Rule': "MAJORITY Admins",
                },
            },
            'Capabilities': self.Capabilities['Channel'],
        }
        self.Profiles = {
            'OrdererGenesis': {
                'Orderer': {
                    'Organizations': self.Organizations[0],
                    'Capabilities': self.Capabilities['Orderer'],
                },
                'Consortiums': {
                    'MyConsortium': {
                        'Organizations': [],
                    },
                },
            },
            'TestChannel': {
                'Consortium': 'MyConsortium',
                'Application': {
                    'Organizations': [],
                    'Capabilities': self.Capabilities['Application'],
                },
            },
        }
        self.Profiles['OrdererGenesis']['Orderer'].update(self.Orderer)
        self.Profiles['OrdererGenesis'].update(self.Channel)
        self.Profiles['TestChannel']['Application'].update(self.Application)
        self.Profiles['TestChannel'].update(self.Channel)
    
    def add_peer_org(self, anchor_peer_number, org_number):
        org_name = 'Org' + str(org_number) + 'MSP'
        msp_id = org_name
        msp_dir = '../crypto-config/peerOrganizations/org' + str(org_number) + '.svc.cluster.local/msp'
        anchor_peer = 'peer' + str(anchor_peer_number) + '-hlf-peer.org' + str(org_number) + '.svc.cluster.local'
        new_org = {
            'Name': org_name,
            'ID': msp_id,
            'MSPDir': msp_dir,
            'Policies': {
                'Readers': {
                    'Type': 'ImplicitMeta',
                    'Rule': "ANY Readers",
                },
                'Writers': {
                    'Type': 'ImplicitMeta',
                    'Rule': "ANY Writers",
                },
                'Admins': {
                    'Type': 'ImplicitMeta',
                    'Rule': "MAJORITY Admins",
                },
            },
            'AnchorPeers': [{
                    'Host': anchor_peer,
                    'Port': 7051,
                },
            ],
        }
        self.Organizations.append(new_org)
        self.Profiles['OrdererGenesis']['Consortiums']['MyConsortium']['Organizations'].append(new_org)
        self.Profiles['TestChannel']['Application']['Organizations'].append(new_org)
    
    def add_orderer(self, ord_number):
        ord_name = 'ord' + str(ord_number) + '-hlf-ord.orderers.svc.cluster.local'
        client_tls_cert = '../crypto-config/ordererOrganizations/orderers.svc.cluster.local/orderers/' + ord_name + '/tls/server.crt'
        server_tls_cert = client_tls_cert
        ord_address = ord_name + ':7050'
        self.Orderer['Addresses'].append(ord_address)
        self.Orderer['EtcdRaft']['Consenters'].append({
            'Host': ord_name,
            'Port': 7050,
            'ClientTLSCert': client_tls_cert,
            'ServerTLSCert': server_tls_cert,
        })