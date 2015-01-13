#!/usr/bin/env python

servername = 'thebomb2'
image = 'Ubuntu 14.04 x64 LTS'
flavor = 'm1.medium'
#management = 'management_network'
#internet = 'internet_network'
#customer = 'customer_network'
script = 'scripts/install_test.sh'

nics=[{'network': 'customer_network', 'ip': 'dhcp'},
      {'network': 'management_network', 'ip': 'dhcp'}]