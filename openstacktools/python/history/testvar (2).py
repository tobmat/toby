#!/usr/bin/env python


servername = 'thebomb8'
image = 'Ubuntu 14.04 x64 LTS'
### Select from images below
"""
['AudioCodes',
 'AudioCodes SEM',
 'Brendan2012',
 'CentOS 6.5 x64',
 'Demo Image CirrOS 0.3.1 9',
 'Horizon',
 'OPENWRT_PG',
 'Qualys',
 'Server2012R2',
 'Ubuntu 14.04 x64 LTS',
 'Vyos 1.0.4',
 'Vyos 1.1.1',
 'Win2012R2',
 'Win2012R2-Cloud']
 """
flavor = 'm1.medium'   #  select from following flavors['m1large', 'm1medium', 'm1small', 'm1tiny', 'm1xlarge']
script = 'scripts/install_test.sh'

### Add or remove nics as needed
nics=[{'network': 'customer_network', 'ip': 'dhcp'},
      {'network': 'management_network', 'ip': 'dhcp'}]
