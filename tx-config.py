import yaml
import Txconfig
import sys


if len(sys.argv) != 3:
    print('Usage: python tx-config.py <number of organizations> <number of orderers>')
    sys.exit(1)

config = Txconfig.Txconfig()
number_of_orgs = int(sys.argv[1])
number_of_orderers = int(sys.argv[2])
for org_num in range(1, number_of_orgs + 1):
    config.add_peer_org(1, org_num)

for ord_num in range(1, number_of_orderers + 1):
    config.add_orderer(ord_num)

with open(r'./configtx.yaml', 'w') as file:
    yaml.dump(config.__dict__, file, default_flow_style=False)
