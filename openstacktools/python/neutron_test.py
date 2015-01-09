from credentials import get_neutron_creds
from neutronclient.neutron import client as neutronclient
from credentials import get_keystone_creds
from keystoneclient.v2_0 import client as keystoneclient

creds = get_keystone_creds()
keystone = keystoneclient.Client(**creds)

ncreds = get_neutron_creds(keystone.auth_token)
neutron = neutronclient.Client('2.0', **ncreds)

print neutron.list_networks()