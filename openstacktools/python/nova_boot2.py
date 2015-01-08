#!/usr/bin/env python
import time
import os
import sys
import novaclient.v1_1.client as nvclient
from credentials import get_nova_creds
#source = sys.argv[1]
source = __import__(sys.argv[1])
#from var import var
test = source.var()
creds = get_nova_creds(test['tenant'])
nova = nvclient.Client(**creds)

image = nova.images.find(name=test['image'])
flavor = nova.flavors.find(name=test['flavor'])
management = nova.networks.find(label=test['management']) 
internet = nova.networks.find(label=test['internet']) 
script = test['script']
#print network.id
networks = []
networks.append({'net-id': management.id})
networks.append({'net-id': internet.id})
instance = nova.servers.create(name=test['servername'],
	                 image=image,
 	                 flavor=flavor, 
	                 key_name="devops", 
	                 nics=networks,
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