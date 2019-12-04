import yaml
import Config
import sys


if len(sys.argv) != 4:
    print('Usage: python network-config.py <number of organizations> <number of peers per organization> <number of orderers>')
    sys.exit(1)

config = Config.Config()
number_of_orgs = int(sys.argv[1])
number_of_peers_per_org = int(sys.argv[2])
number_of_orderers = int(sys.argv[3])
for org_num in range(1, number_of_orgs + 1):
    config.add_client(org_num)
    config.add_organization(org_num)
    for peer_num in range(1, number_of_peers_per_org + 1):
        config.add_peer(peer_num, org_num)

for ord_num in range(1, number_of_orderers + 1):
    config.add_orderer(ord_num)

with open(r'./network-config.yaml', 'w') as file:
    yaml.dump(config.__dict__, file, default_flow_style=False)
