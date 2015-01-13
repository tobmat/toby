#!/usr/bin/env python

def var():
    value = { 'tenant' : 'admin',
              'servername' : 'thebomb2',
              'image' : 'Ubuntu 14.04 x64 LTS',
              'flavor' : 'm1.medium',
              'management' : 'management_network',
              'internet' : 'internet_network',
              'script' : 'scripts/install_test.sh'}
    return value