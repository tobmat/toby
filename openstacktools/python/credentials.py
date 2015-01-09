#!/usr/bin/env python
import os

def get_keystone_creds(tenant=os.environ['OS_TENANT_NAME']):
    d = {}
    d['username'] = os.environ['OS_USERNAME']
    d['password'] = os.environ['OS_PASSWORD']
    d['auth_url'] = os.environ['OS_AUTH_URL']
    d['tenant_name'] = tenant
    return d

def get_nova_creds(tenant=os.environ['OS_TENANT_NAME']):
    d = {}
    d['username'] = os.environ['OS_USERNAME']
    d['api_key'] = os.environ['OS_PASSWORD']
    d['auth_url'] = os.environ['OS_AUTH_URL']
    d['project_id'] = tenant
    return d

def get_glance_creds(auth_token):
    d = {}
    d['endpoint'] = 'http://198.11.218.194:9292'
    d['token'] = auth_token
    return d

def get_neutron_creds(auth_token):
    d = {}
    d['endpoint_url'] = 'http://198.11.218.194:9696'
    d['token'] = auth_token
    return d