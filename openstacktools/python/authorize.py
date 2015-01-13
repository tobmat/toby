from glanceclient import client as glanceClient
from neutronclient.neutron import client as neutronclient
from heatclient.client import Client as heatClient
import novaclient.v1_1.client as nvclient
from keystoneclient.v2_0 import client as keystoneclient
import os 

def get_keystone_creds(tenant):
    d = {}
    d['username'] = os.environ['OS_USERNAME']
    d['password'] = os.environ['OS_PASSWORD']
    d['auth_url'] = os.environ['OS_AUTH_URL']
    d['tenant_name'] = tenant
    return d

creds = get_keystone_creds(os.environ['OS_TENANT_NAME'])
keystone = keystoneclient.Client(**creds)

def get_nova_creds(tenant):
  d = {}
  d['username'] = os.environ['OS_USERNAME']
  d['api_key'] = os.environ['OS_PASSWORD']
  d['auth_url'] = os.environ['OS_AUTH_URL']
  d['project_id'] = tenant
  return d

creds = get_nova_creds(os.environ['OS_TENANT_NAME'])
nova = nvclient.Client(**creds)

glance_endpoint = keystone.service_catalog.url_for(service_type='image', endpoint_type='publicURL')
glance = glanceClient.Client('1', endpoint=glance_endpoint, token=keystone.auth_token)

neutron_endpoint = keystone.service_catalog.url_for(service_type='network', endpoint_type='publicURL')
neutron = neutronclient.Client('2.0', endpoint_url=neutron_endpoint, token = keystone.auth_token)

### Heat is not currently available
#heat_endpoint = keystone.service_catalog.url_for(service_type='orchestration', endpoint_type='publicURL')
#heat = heatClient('1', endpoint=heat_endpoint, token=keystone.auth_token)