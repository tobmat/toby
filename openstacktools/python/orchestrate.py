#!/usr/bin/env python
import os

print 'Building 1st server'
os.system("nova_boot2.py different")
print 'Building 2nd server'
os.system("nova_boot2.py var")