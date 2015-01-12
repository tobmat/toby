#!/usr/bin/env python

servername = 'DEV-DB-02'
image = 'Server2012R2'
flavor = 'm1.medium'
#management = 'management_network'
#internet = 'internet_network'
#customer = 'customer_network'
script = 'scripts/install_sql.ps1'

nics=[{'network': 'customer_network', 'ip': 'dhcp'},
      {'network': 'management_network', 'ip': 'dhcp'}]

