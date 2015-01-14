#!/usr/bin/env python
import sys
from class2 import authorize

def main(server,tenant):
  import time
  import os

  a = authorize(tenant)

  try: 
   delete = a.nova.servers.find(name = server)
   a.nova.servers.delete(delete)
   print "%s has been deleted..." % server
  except: 
   print "The 'test' server doesn't exist..."

if __name__ == "__main__":
   main(sys.argv[1], sys.argv[2])

