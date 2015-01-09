#from credentials import get_glance_creds
from heatclient.client import Client as heatClient
from credentials import get_keystone_creds
from keystoneclient.v2_0 import client as keystoneclient
from tenant import get_tenant

tenant = get_tenant()
creds = get_keystone_creds(tenant)
keystone = keystoneclient.Client(**creds)
heat_endpoint = keystone.service_catalog.url_for(service_type='orchestration', endpoint_type='publicURL')

heat = heatClient('1', endpoint=heat_endpoint, token=keystone.auth_token)

stacks = heat.stacks.list()
print list(stacks)