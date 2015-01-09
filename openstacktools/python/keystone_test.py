from credentials import get_keystone_creds
from keystoneclient.v2_0 import client as keystoneclient

creds = get_keystone_creds()
keystone = keystoneclient.Client(**creds)

print keystone.endpoints.list()