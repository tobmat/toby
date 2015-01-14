#!/usr/bin/env python
import sys
import time
from authorize_class import authorize

def main(variables,tenant):

  #import os

  #os.environ['OS_TENANT_NAME'] = tenant
  #import authorize as a
  a = authorize(tenant)

  source = __import__(variables)

  servername = source.servername
  image = a.nova.images.find(name = source.image)
  flavor = a.nova.flavors.find(name = source.flavor)
  script = source.script
  security_groups= source.security_groups

  nicList = []
  for n in source.nics:
      if n['ip'].lower() == 'dhcp'.lower():
          net = a.nova.networks.find(label=n['network']) 
          nicList.append({'net-id': net.id})
      else:
          nicList.append({'net-id': net.id,
                          'v4-fixed-ip': n['ip']})

  instance = a.nova.servers.create(name = servername,
                                   image=image,
                                   flavor=flavor,
                                   key_name="devops", 
                                   nics=nicList,
                                   userdata=open(script).read(),
                                   security_groups = security_groups)

  #Poll at 5 second intervals, until the status is no longer 'BUILD'
  status = instance.status
  print "status: %s" % status
  while status == 'BUILD':
      time.sleep(3)
      # Retrieve the instance again so the status field updates
      instance = a.nova.servers.get(instance.id)
      status = instance.status
      print "status: BUILDING..."
  print "status: %s" % status
  print instance

if __name__ == "__main__":
   main(sys.argv[1], sys.argv[2])

