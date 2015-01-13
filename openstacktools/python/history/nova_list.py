#!/usr/bin/env python
import os
import sys
import novaclient.v1_1.client as nvclient
from credentials import get_nova_creds
#from tenant import get_tenant
#import tenant
print os.environ['OS_VAR']
source = __import__(os.environ['OS_VAR'])


creds = get_nova_creds()
nova = nvclient.Client(**creds)

nicList = []
for n in source.nics:
    if n['ip'].lower() == 'dhcp'.lower():
        net = nova.networks.find(label=n['network']) 
        nicList.append({'net-id': net.id})
    else:
        nicList.append({'net-id': net.id,
                        'v4-fixed-ip': n['ip']})

print nicList
#from var import var
#test = source.var()
print source.image
#tenant = get_tenant()

#print nova.servers.list()
#print nova.images.list()
#print nova.images.find(name="Ubuntu 14.04 x64 LTS")
#print nova.networks.find(label="management_network")
#print nova.networks.list()
#os.environ['OS_TENANT_NAME'] = "Orchestrated"
#print creds
#test = sys.argv[1]
#print test