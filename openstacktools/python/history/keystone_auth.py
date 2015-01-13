from keystoneclient.v2_0 import client as keystoneclient

def get_keystone_creds(tenant=os.environ['OS_TENANT_NAME']):
    d = {}
    d['username'] = os.environ['OS_USERNAME']
    d['password'] = os.environ['OS_PASSWORD']
    d['auth_url'] = os.environ['OS_AUTH_URL']
    d['tenant_name'] = tenant
    return d

creds = get_keystone_creds('DEV')
keystone = keystoneclient.Client(**creds)