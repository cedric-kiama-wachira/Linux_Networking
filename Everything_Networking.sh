#!/bin/bash

# IPv4(Decimal Format) and IPv6(Hexadecimal Format) CIDR

# Get link devices
ip link

# 
ip address
ip add
ip -c add
ip -c address

# To bring an interface ip
sudo ip link set dev enp2s0 up
sudo ip link set dev wlp3s0 up

# Adding an IP address
sudo ip address add 192.168.5.55/24 dev wlp3s0
sudo ip address add fe80::13fa:673f:1594:7df9/64 dev wlp3s0

# Delete the added IP address
sudo ip address delete 192.168.5.55/24 dev wlp3s0
sudo ip address delete fe80::13fa:673f:1594:7df9/64 dev wlp3s0

# Ubuntu used Netplan to manage Network settings, to see current settings we use
netplan get 

# Settings are stored in /etc/netplan directory
ls /etc/netplan
01-network-manager-all.yaml
cat /etc/netplan/01-network-manager-all.yaml

# Once the file is modified to suit our configuration - we can update it using the below command
sudo netplan try --timeout 30
sudo netplan apply

# To check the dns resolvers we can use to get the full statement or shorten it specifically for DNS
resolvectl status
resolvectl dns
# To make the DNS resolvers Globally for all  interfaces we can edit below file the DNS section
vi /etc/systemd/resolved.conf
DNS= 1.1.1.1 9.9.9.9
sudo systemctl restart systemd-resolved.service

# To get additional Information on setting netplan we can use
man netplan
/address label # We can do a search here to see an example setting
/Default routes # A couple of times until I get to section that says "The most common need for routing concerns the definition..." 

ls /usr/share/doc/netplan/examples

cat  /usr/share/doc/netplan/examples/dhcp.yaml
cat  /usr/share/doc/netplan/examples/static.yaml

# To set the network settings on Centos and other redhat distributions we can edit the below file
cat /etc/resolv.conf

# To get the routes and network config in Centos and other redhat linux distributions we can check out the following directory
ls /etc/sysconfig/network-scripts/
cat /etc/sysconfig/network-scripts/ifcfg-eth0

# We can use the following to configure network settings
sudo nmtui
sudo nmcli device reapply eth0

# Check network manager in centos and redhat linux distributions is working
sudo systemctl status NetworkManager.service
sudo systemctl enable NetworkManager.service

# If network manager is not running on the system we can install it using
sudo dnf install NetworkManager

# To list all connections configured into our system
nmcli connection show

# To ensure that a connection from above list will be enabled at boot time, we use below
nmcli connection modify System eth0 autoconnect yes

# Stop, start and check the status of network services
sudo ss -ltunp # l is for listen, t for tcp connections,u
               # u for udp connectuions, 
               # n for numeric values(full Ip address plus port number) 
               # and p shows the process involved

# From above output we can explore the process
ps 626

# Or check out the files opened by our process using
sudo lsof -p 51206

# An alternative to ss is the use of the command
sudo netstat -ltunp

# Configure bridge and bond network devices - glue two devices into one device

# Bond Modes 0-6
# 0 - Round Robin, the network devices here are used in sequential modes
# 1 - Active Backup, it uses only one interface and keeps the other ones as backup
# 2 - XOR, for each connection initially established, it will continue to use that interface
# 3 - Broadcast, all data is sent to all interfaces at once
# 4 - IEEE 802.3ad, used to increase the network rates above what the interface can support
# 5 - Adaptive transmit load balancing, it load balances the traffic on the devices, ie devices that are least busy
# 6 - Adaptive load balancing, it tries to load balance both outgoing and incoming traffice
# In the contexts of bonds, all interfaces used are called ports

# In Ubuntu let's explore the example to see how to configure bridge and bonding using netplan
ls /usr/share/doc/netplan/examples 
bridge.yaml and bonding.yaml
cat /usr/share/doc/netplan/examples/bridge.yaml
sudo cp /usr/share/doc/netplan/examples/bridge.yaml /etc/netplan/99-bridge.yaml

ip -c link
enp2s0
enp3s0

sudo vi /etc/netplan/99-bridge.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    enp2s0:
      dhcp4: no
    enp3s0:
      dhcp4: no
  bridges:
    br0:
      dhcp4: yes
      interfaces:
        - enp2s0
        - enp3s0

sudo netplan try
# Hit ENTER

# Bond configuration
sudo rm /etc/netplan/99-bridge.yaml
sudo ip link delete br0
sudo shutdown -R
sudo cp /usr/share/doc/netplan/examples/bonding.yaml /etc/netplan/99-bonding.yaml
sudo vi /etc/netplan/99-bonding.yaml
network:
  version: 2
  renderer: networkd
  ethernets: # Added this section
    enp2s0:
      dhcp4: no
    enp3s0:
      dhcp4: no
  bonds:
    bond0:
      dhcp4: yes
      interfaces:
        - enp2s0
        - enp3s0
      parameters:
        mode: active-backup
        primary: enp2s0
sudo netplan try
sudo netplan apply
ip -c addr
cat /proc/net/bonding/bond0

man netplan
# /bonding # Third search result for the mode types under parameters


# Configure Firewallls and Packet Filtering
# Application Firewall is one
# In ubuntu we have network firewalls

sudo ufw status verbose
sudo ufw allow 22
sudo ufw allow 22/tcp
sudo ufw allow 22/udp
sudo ufw enable
sudo ufw status verbose

# Creating a rule to allow traffic from a specific machine to any of our network devices
sudo ufw allow from 1.1.1.1 to any port 22
sudo ufw status numbered verbose

# Creating a rule to allow traffic from a specific machine to a specific network device on our machine
sudo ufw allow from 1.1.1.1 to 2.2.2.2 port 22

# If there is a list of rules on the firewall and the first one is open for all connections we can delete it
sudo ufw delete 1

# If we need to allow a rule based on a range of IPs in a simillar location we could use
sudo ufw allow from 10.11.12.0/24 to any port 22

# Will do the same but allow to ALL ports
sudo ufw allow from 10.11.12.0/24

# To deny access from a specific IP to the above network range
sudo ufw deny from 10.11.12.100

# To make sure that the above works we need to rearrange the rule
sudo ufw deny insert 3 deny from 10.11.12.100

# To add a rule on a specific interface such us outgoing
sudo ufw deny out on enp2s0 to 1.1.1.1

# Lets build a complicated rule
sudo ufw allow in on enp2s0 from 3.3.3.3 to 4.4.4.4 port 999 proto tcp
sudo ufw allow out on enp2s0 from 3.3.3.3 to 4.4.4.4 port 999 proto tcp

# Implement proxies and load balancers in Ubuntu
sudo apt install nginx -y
sudo vi /etc/nginx/sites-available/proxy.conf







