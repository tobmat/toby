#from credentials import get_glance_creds
from glanceclient import client as glanceClient
from credentials import get_keystone_creds
from keystoneclient.v2_0 import client as keystoneclient
from tenant import get_tenant

tenant = get_tenant()
creds = get_keystone_creds(tenant)
keystone = keystoneclient.Client(**creds)
glance_endpoint = keystone.service_catalog.url_for(service_type='image', endpoint_type='publicURL')

#gcreds = get_glance_creds(keystone.auth_token)
glance = glanceClient.Client('1', endpoint=glance_endpoint, token=keystone.auth_token)
#glance = glanceClient.Client(version='1',**gcreds)

images = glance.images.list()
print list(images)