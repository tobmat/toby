#!/usr/bin/env python
import os
import sys
import novaclient.v1_1.client as nvclient
from credentials import get_nova_creds
creds = get_nova_creds('Orchestrated')
nova = nvclient.Client(**creds)
#print nova.servers.list()
#print nova.images.list()
#print nova.images.find(name="Ubuntu 14.04 x64 LTS")
#print nova.networks.find(label="management_network")
#print nova.networks.list()
#os.environ['OS_TENANT_NAME'] = "Orchestrated"
print creds
test = sys.argv[1]
print test