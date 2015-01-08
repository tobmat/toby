#cloud-config
password: Interactive2014
chpasswd: { expire: False }
ssh_pwauth: True

# Bash Script
runcmd:
 - hostname toby.oncaas.com
 - echo "127.0.0.1 `hostname` `hostname -s`" | sudo tee -a /etc/hosts
 - echo 'auto eth1' >> /etc/network/interfaces
 - echo 'iface eth1 inet dhcp' >> /etc/network/interfaces
 - ifup eth1
 - ufw disable
