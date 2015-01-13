#!/usr/bin/env python
import time
import os
import sys
import novaclient.v1_1.client as nvclient
from credentials import get_nova_creds

source = __import__(os.environ['OS_VAR'])

creds = get_nova_creds()
nova = nvclient.Client(**creds)

image = nova.images.find(name = source.image)
flavor = nova.flavors.find(name = source.flavor)
script = source.script

nicList = []
for n in source.nics:
    if n['ip'].lower() == 'dhcp'.lower():
        net = nova.networks.find(label=n['network']) 
        nicList.append({'net-id': net.id})
    else:
        nicList.append({'net-id': net.id,
                        'v4-fixed-ip': n['ip']})

instance = nova.servers.create(name = source.servername,
	                 image=image,
 	                 flavor=flavor, 
	                 key_name="devops", 
	                 nics=nicList,
	                 userdata=open(script).read())

#Poll at 5 second intervals, until the status is no longer 'BUILD'
status = instance.status
print "status: %s" % status
while status == 'BUILD':
    time.sleep(3)
    # Retrieve the instance again so the status field updates
    instance = nova.servers.get(instance.id)
    status = instance.status
print "status: %s" % status
print instance