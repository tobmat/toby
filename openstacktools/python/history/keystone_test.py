from credentials import get_keystone_creds
from keystoneclient.v2_0 import client as keystoneclient
#from tenant import get_tenant
import tenant

#tenant = get_tenant()
#creds = get_keystone_creds(tenant)
creds = get_keystone_creds(tenant.tenant_name)
keystone = keystoneclient.Client(**creds)
#print tenant.tenant_name

glance_endpoint = keystone.service_catalog.url_for(service_type='image', endpoint_type='publicURL')

#neutron_endpoint = keystone.service_catalog.url_for(service_type='network', endpoint_type='publicURL')

#heat_endpoint = keystone.service_catalog.url_for(service_type='orchestration', endpoint_type='publicURL')

print glance_endpoint
#print neutron_endpoint
#print heat_endpoint
#print keystone.endpoints.list() 