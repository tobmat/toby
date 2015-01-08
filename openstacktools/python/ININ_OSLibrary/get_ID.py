from authenticate2 import neutron
#from authenticate2 import keystone
from authenticate2 import nova

def get_ID(name, source):
    """
    Considering most of the Openstack IDs are mapped the same way, this is
    pretty easy to reuse
    """
    for i in source:
        if i.name == name:
            return i.id
    return False


def get_tenantID(name):
    return get_ID(name, keystone().tenants.list())

def get_roleID(name):
    return get_ID(name, keystone().roles.list())

def get_userID(name):
    return get_ID(name, keystone().users.list())


def get_flavorID(name):
    return get_ID(name, nova().flavors.list())


def get_imageID(name):
    return get_ID(name, nova().images.list())


def get_instanceID(tenant, name):
    return get_ID(name, nova(tenant).servers.list())


def get_securityGroupID(tenant, securityGroup):
    group = nova(tenant).security_groups.find(name=securityGroup)
    return group


def get_networkID(tenant, name):
    try:
        return neutron(tenant).list_networks(name=name)['networks'][0]['id']
    except:
        print "Could not find network ID for " + name + "!"
        return False
        pass

def get_routerID(tenant, name):
    try:
        return neutron(tenant).list_routers(name=name)['routers'][0]['id']
    except:
        return False
        pass

def get_subnetID(tenant, name):
    try:
        return neutron(tenant).list_subnets(name=name)['subnets'][0]['id']
    except:
        return False
        pass


#get_networkID('admin', 'phase3_network')