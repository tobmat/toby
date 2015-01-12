#from credentials import get_neutron_creds
from neutronclient.neutron import client as neutronclient
from credentials import get_keystone_creds
from keystoneclient.v2_0 import client as keystoneclient
#from tenant import get_tenant
import tenant

#tenant = get_tenant()

creds = get_keystone_creds(tenant.tenant_name)
keystone = keystoneclient.Client(**creds)
neutron_endpoint = keystone.service_catalog.url_for(service_type='network', endpoint_type='publicURL')

#ncreds = get_neutron_creds(keystone.auth_token)
#neutron = neutronclient.Client('2.0', **ncreds)
neutron = neutronclient.Client('2.0', endpoint_url=neutron_endpoint, token = keystone.auth_token)


print neutron.list_networks()