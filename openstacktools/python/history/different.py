#!/usr/bin/env python

def var():
    value = { 'tenant' : 'DEV',
              'servername' : 'thebomb4',
              'image' : 'Ubuntu 14.04 x64 LTS',
              'flavor' : 'm1.small',
              'management' : 'management_network',
              'internet' : 'internet_network',
              'customer' : 'customer_network',
              'script' : '../scripts/install_test.sh'}
    return value