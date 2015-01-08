import os
#from ConfigParser import SafeConfigParser

#package_directory = os.path.dirname(os.path.abspath(__file__))

#parser = SafeConfigParser()
#parser.read(package_directory + "/config.ini")
username = os.environ['OS_USERNAME']
password = os.environ['OS_PASSWORD']
auth_url = os.environ['OS_AUTH_URL']

###print os.environ['OS_TENANT_ID']
###print os.environ['OS_TENANT_NAME']
neutron_endpoint = os.environ['OS_NEUTRON_EP']
#keystone_endpoint = parser.get('endpoints', 'keystone_endpoint')
#image_endpoint = parser.get('endpoints', 'image_endpoint')
#service_token = parser.get('admin', 'service_token') # Obtain from openrc on compute node.

# Imports
from keystoneclient.v2_0 import client as keystoneclient
from neutronclient.neutron import client as neutronclient
from novaclient.v1_1 import client as novaClient
###from glanceclient import client as glanceClient


def nova(tenant_name='admin'):
    nova = novaClient.Client(username=username,
                             api_key=password,
                             project_id=tenant_name,
                             auth_url=auth_url)
    return nova

def keystone(tenant_name=False):
    if (tenant_name):
        keystone = keystoneclient.Client(username=username,
                                         password=password,
                                         auth_url=auth_url,
                                         tenant_name=tenant_name)
    #else:
    #    keystone = keystoneclient.Client(auth_url=auth_url,
    #                                     token=service_token,
    #                                     endpoint=keystone_endpoint)
    return keystone
def neutron(tenant_name):
    neutron = neutronclient.Client('2.0', endpoint_url=neutron_endpoint, token = keystone(tenant_name).auth_token)
    return neutron
'''

def glance(tenant_name):
    glance = glanceClient.Client('1', endpoint=image_endpoint, token=keystone(tenant_name).auth_token)
    return glance
'''