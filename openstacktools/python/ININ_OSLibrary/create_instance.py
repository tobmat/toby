from authenticate2 import nova
from get_ID import get_instanceID
from get_ID import get_networkID
from get_ID import get_imageID
from get_ID import get_flavorID

def create_instance(name, tenant, image, flavor, nics, script=False, userdata=False, configDrive=True, security_groups={'default'}, files=False):
    if get_instanceID(tenant, name) is False:
        nicList = []
        for n in nics:
            if n['ip'].lower() == 'dhcp'.lower():
                nicList.append({'net-id': get_networkID(tenant, n['network'])})
            else:
                nicList.append({'net-id': get_networkID(tenant, n['network']),
                                'v4-fixed-ip': n['ip']})
        if (files):
            for key, value in files.iteritems():
                files[key] = open(value).read()
            nova(tenant).servers.create(name=name,
                              image=get_imageID(image),
                              flavor=get_flavorID(flavor),
                              nics=nicList,
                              config_drive=configDrive,
                              userdata=open(userdata).read(),
                              security_groups=security_groups,
                              files=files)
        else:
            nova(tenant).servers.create(name=name,
                                        image=get_imageID(image),
                                        flavor=get_flavorID(flavor),
                                        nics=nicList,
                                        config_drive=configDrive,
                                        userdata=open(userdata).read(),
                                        security_groups=security_groups)
        print "Launched '" + name + "' instance successfully!"
    else:
        print "Instance with name '" + name + "' already exists!  Skipping."