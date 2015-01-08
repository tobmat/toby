# Initialize Library
import ININ_OSLibrary
lib = ININ_OSLibrary

"""
### Mirantis code
lib.create_instance(name='sql01-dev.oncaas.com',
                    tenant='admin',
                    image='Server2012R2',
                    flavor='m1.large',
                    nics=[{'network': 'phase3_network', 'ip': 'dhcp'},
                          {'network': 'management_network', 'ip': 'dhcp'}],
                    userdata='scripts/install_sql.ps1',
                    security_groups={'secgroup_open'})
"""
### Piston code
lib.create_instance(name='CUST1-DB-01',
                    tenant='Phase3_CUST2',
                    image='Server2012R2',
                    flavor='m1.medium',
                    nics=[{'network': 'CUST_INTERNAL_SECURE', 'ip': '10.0.0.100'},
                          {'network': 'CUST_EXT-MGMT_NET', 'ip': '62.193.13.171'}],
                    userdata='scripts/install_sql.ps1',
                    security_groups={'default'})