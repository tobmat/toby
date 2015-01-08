# Initialize Library
import ININ_OSLibrary
lib = ININ_OSLibrary
'''
lib.create_instance(name='toby.oncaas.com',
                    tenant='admin',
                    image='Ubuntu 14.04 x64 LTS',
                    flavor='m1.large',
                    nics=[{'network': 'phase3_network', 'ip': 'dhcp'},
                          {'network': 'management_network', 'ip': 'dhcp'}],
                    userdata='scripts/install_test.sh',
                    security_groups={'secgroup_open'})
'''
lib.create_instance(name='chef.oncaas.com',
                    tenant='admin',
                    image='Ubuntu 14.04 x64 LTS',
                    flavor='m1.large',
                    nics=[{'network': 'management_network', 'ip': 'dhcp'}],
                    userdata='scripts/install_chef.sh',
                    security_groups={'secgroup_open'})
'''
### Piston code
lib.create_instance(name='CHEF.oncaas.com',
                    tenant='DEV',
                    image='Ubuntu 14.04 x64 LTS',
                    flavor='m1.large',
                    nics=[{'network': 'CUST_EXT-MGMT_NET', 'ip': 'dhcp'}],
                    userdata='scripts/install_chef.sh',
                    security_groups={'default'})
'''