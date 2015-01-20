from glanceclient import client as glanceClient
from neutronclient.neutron import client as neutronclient
from heatclient.client import Client as heatClient
import novaclient.v1_1.client as nvclient
from keystoneclient.v2_0 import client as keystoneclient
import os 
class authorize(object):

 def __init__(self, tenant):
  self.tenant = tenant
  def get_keystone_creds(tenant = self.tenant):
    d = {}
    d['username'] = os.environ['OS_USERNAME']
    d['password'] = os.environ['OS_PASSWORD']
    d['auth_url'] = os.environ['OS_AUTH_URL']
    d['tenant_name'] = tenant
    return d

  self.creds = get_keystone_creds()
  self.keystone = keystoneclient.Client(**self.creds)

  def get_nova_creds(tenant = self.tenant):
   d = {}
   d['username'] = os.environ['OS_USERNAME']
   d['api_key'] = os.environ['OS_PASSWORD']
   d['auth_url'] = os.environ['OS_AUTH_URL']
   d['project_id'] = tenant
   return d

  self.creds = get_nova_creds()
  self.nova = nvclient.Client(**self.creds)

  glance_endpoint = self.keystone.service_catalog.url_for(service_type='image', endpoint_type='publicURL')
  self.glance = glanceClient.Client('1', endpoint=glance_endpoint, token= self.keystone.auth_token)

  neutron_endpoint = self.keystone.service_catalog.url_for(service_type='network', endpoint_type='publicURL')
  self.neutron = neutronclient.Client('2.0', endpoint_url=neutron_endpoint, token = self.keystone.auth_token)

  ### Heat is not currently available
  #heat_endpoint = keystone.service_catalog.url_for(service_type='orchestration', endpoint_type='publicURL')
  #heat = heatClient('1', endpoint=heat_endpoint, token=keystone.auth_token)