#!/usr/bin/env python
import time
import novaclient.v1_1.client as nvclient
from credentials import get_nova_creds
creds = get_nova_creds()
nova = nvclient.Client(**creds)
image = nova.images.find(name="Ubuntu 14.04 x64 LTS")
flavor = nova.flavors.find(name="m1.medium")
management = nova.networks.find(label="management_network") 
internet = nova.networks.find(label="internet_network") 
script = 'scripts/install_test.sh'
#print network.id
networks = []
networks.append({'net-id': management.id})
networks.append({'net-id': internet.id})
instance = nova.servers.create(name="toby3",
	                 image=image,
 	                 flavor=flavor, 
	                 key_name="devops", 
	                 nics=networks,
	                 userdata=open(script).read())

#Poll at 5 second intervals, until the status is no longer 'BUILD'
status = instance.status
while status == 'BUILD':
    time.sleep(5)
    # Retrieve the instance again so the status field updates
    instance = nova.servers.get(instance.id)
    status = instance.status
print "status: %s" % status