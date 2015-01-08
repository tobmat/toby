#cloud-config
password: Interactive2014
chpasswd: { expire: False }
ssh_pwauth: True

# Bash Script
runcmd:
 - hostname chef.oncaas.com
 - echo "127.0.0.1 `hostname` `hostname -s`" | sudo tee -a /etc/hosts
 - echo 'auto eth1' >> /etc/network/interfaces
 - echo 'iface eth1 inet dhcp' >> /etc/network/interfaces
 - ifup eth1
 - cd /tmp
 - wget 'https://packagecloud.io/chef/stable/download?distro=precise&filename=chef-server-core_12.0.1-1_amd64.deb'
 - wget 'https://packagecloud.io/chef/stable/download?distro=precise&filename=opscode-analytics_1.0.4-1_amd64.deb'
 - wget 'https://packagecloud.io/chef/stable/download?distro=precise&filename=opscode-manage_1.6.2-1_amd64.deb'
 - wget 'https://packagecloud.io/chef/stable/download?distro=precise&filename=opscode-reporting_1.1.6-1_amd64.deb'
 - wget 'https://packagecloud.io/chef/stable/download?distro=precise&filename=opscode-push-jobs-server_1.1.3-1_amd64.deb'
 - rename 's/download\?distro=precise&filename=//' *
 - dpkg -i chef-server-core_12.0.1-1_amd64.deb
 - su - -c '/usr/bin/chef-server-ctl reconfigure'
 - dpkg -i opscode-manage_1.6.2-1_amd64.deb
 - su - -c 'opscode-manage-ctl reconfigure'
 - su - -c 'chef-server-ctl user-create admin Dev Ops devops@inin.com "Interactive2014"'
 - su - -c 'chef-server-ctl org-create caas CAAS -a admin'
 - ufw disable

#dpkg -i opscode-analytics_1.0.4-1_amd64.deb
#dpkg -i opscode-reporting_1.1.6-1_amd64.deb
#dpkg -i opscode_push-jobs_server_1.1.3-1_amd64.deb
