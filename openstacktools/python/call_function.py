#!/usr/bin/env python
import os
import novaclient.v1_1.client as nvclient
from credentials import get_test_creds
from var import var
test = var()
print test
creds = get_test_creds(test['Tenant'])
print creds
print test['image']

#creds = get_nova_creds()
#nova = nvclient.Client(**creds)
#print nova.servers.list()
#print nova.images.list()
#print nova.images.find(name="Ubuntu 14.04 x64 LTS")
#print nova.networks.find(label="management_network")
#print nova.networks.list()
#os.environ['OS_TENANT_NAME'] = "Orchestrated"
#print os.environ['OS_TENANT_NAME']