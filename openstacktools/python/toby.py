import os
os.environ['OS_TENANT_NAME'] = "DEV"
import authorize as a
import pprint

### Nova Tests Here

### List networks by name
n = a.nova.networks.list()
#n = a.nova.servers.list()
#n = a.nova.images.list()
#n = a.nova.flavors.list()

#print type(n)
#print dir(n[2])


t = []
for net in n:
	#print net.human_id
	#new = net.name
	new = net.human_id
	text = new.encode('ascii','ignore')
	t.append(text)

t.sort()

pprint.pprint(t) 

### Heat Tests Here (Currently Not available... waiting on vendor)
#stacks = a.heat.stacks.list()
#print list(stacks)

#t= a.keystone.endpoints.list() 

#print '\n'.join(end_output)
#print os.listdir("scripts/")  

##pprint.pprint(t)
### Glance Tests Here
#images = a.glance.images.list()
#print list(images)

### Neutron Tests Here
#t =  a.neutron.list_networks()