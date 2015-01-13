import keystone_auth

#glance_endpoint = keystone.service_catalog.url_for(service_type='image', endpoint_type='publicURL')

print keystone_auth.keystone.endpoints.list() 