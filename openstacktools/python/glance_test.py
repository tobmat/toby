from credentials import get_glance_creds
from glanceclient import client as glanceClient
from credentials import get_keystone_creds
from keystoneclient.v2_0 import client as keystoneclient

creds = get_keystone_creds()
keystone = keystoneclient.Client(**creds)

gcreds = get_glance_creds(keystone.auth_token)
glance = glanceClient.Client(version='1',**gcreds)

images = glance.images.list()
print list(images)