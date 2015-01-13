#!/usr/bin/env python
import os

#print 'Building 1st server'
#os.system("nova_boot2.py different")
#print 'Building 2nd server'
#os.system("nova_boot2.py var")

os.environ['OS_TENANT_NAME'] = "DEV"
os.environ['OS_VAR'] = "sqlvar"

os.system("nova_boot3.py")
#os.system("nova_list.py")