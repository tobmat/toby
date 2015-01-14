import os
#os.environ['OS_TENANT_NAME'] = "DEV"
#import authorize as a
#os.environ['OS_TENANT_NAME'] = "TEST_META"
#import authorize as b
import pprint


from authorize_class import authorize

b = authorize('DEV')
a = authorize('TEST_META')

### Nova Tests Here

### List networks by name
#n = a.nova.networks.list()
n = b.nova.servers.list()
t = a.nova.servers.list()

#pprint.pprint(n)
#pprint.pprint(t)

z = a.nova.images.list()
y = a.nova.flavors.list()

#pprint.pprint(z)
#pprint.pprint(y)

print type(y)
print dir(y[2])
#try: 
# delete = a.nova.servers.find(name = 'thebomb9')
# a.nova.servers.delete(delete)
#except: 
# print "The 'test' server doesn't exist..."
#print delete

#t = []
#for net in n:
	#print net.human_id
	#new = net.name
#	text = new.encode('ascii','ignore')
#	t.append(text)

#t.sort()

#pprint.pprint(t) 



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