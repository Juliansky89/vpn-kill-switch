////////////////////////////////////////////////////////////////////////
    #!/bin/bash

###########################
## debugging
###########################

#set -x

###########################
## error_handler
###########################

error_handler() {
  echo "##################################################"
  echo "VPN firewall script failed!"
  echo "##################################################"
  exit 1
}



###########################
## configuration
###########################

## IP address of the VPN server.
## Get the IP using: nslookup vpn-example-server.org
## Example: seattle.vpn.riseup.net
## Some providers provide multiple VPN servers.
## You can enter multiple IP addresses, separated by spaces
VPN_SERVERS="ar1.ibvpn.com au1.ibvpn.com au2.ibvpn.com au3.ibvpn.com at1.ibvpn.com be1.ibvpn.com bg1.ibvpn.com  br1.ibvpn.com ca1.ibvpn.com ca2.ibvpn.com ca3.ibvpn.com ca4.ibvpn.com ca5.ibvpn.com ca6.ibvpn.com ca7.ibvpn.com ca8.ibvpn.com ca9.ibvpn.com ca10.ibvpn.com ch1.ibvpn.com ch2.ibvpn.com cl1.ibvpn.com cn1.ibvpn.com cn2.ibvpn.com cz1.ibvpn.com de1.ibvpn.com de2.ibvpn.com de3.ibvpn.com de4.ibvpn.com dk1.ibvpn.com eg1.ibvpn.com es1.ibvpn.com es2.ibvpn.com es3.ibvpn.com fi1.ibvpn.com fi2.ibvpn.com fi2.ibvpn.com fr1.ibvpn.com fr2.ibvpn.com fr3.ibvpn.com fr4.ibvpn.com gr1.ibvpn.com hk1.ibvpn.com hk2.ibvpn.com hu1.ibvpn.com ie1.ibvpn.com ie2.ibvpn.com ie3.ibvpn.com il1.ibvpn.com il2.ibvpn.com in1.ibvpn.com in2.ibvpn.com in3.ibvpn.com in4.ibvpn.com in5.ibvpn.com is1.ibvpn.com it1.ibvpn.com it2.ibvpn.com it3.ibvpn.com it4.ibvpn.com jp1.ibvpn.com jp2.ibvpn.com kr1.ibvpn.com lt1.ibvpn.com lu1.ibvpn.com lv1.ibvpn.com mx1.ibvpn.com nl1.ibvpn.com nl2.ibvpn.com nl3.ibvpn.com nl4.ibvpn.com nl5.ibvpn.com nl6.ibvpn.com nl7.ibvpn.com nl8.ibvpn.com nl9.ibvpn.com no1.ibvpn.com nz1.ibvpn.com pa1.ibvpn.com pa2.ibvpn.com pl1.ibvpn.com pt1.ibvpn.com ro1.ibvpn.com ru1.ibvpn.com ru2.ibvpn.com ru3.ibvpn.com sa1.ibvpn.com se1.ibvpn.com se2.ibvpn.com se3.ibvpn.com se4.ibvpn.com se5.ibvpn.com sg1.ibvpn.com sg2.ibvpn.com si1.ibvpn.com tr1.ibvpn.com ua1.ibvpn.com ua2.ibvpn.com uk1.ibvpn.com uk2.ibvpn.com uk3.ibvpn.com uk4.ibvpn.com uk5.ibvpn.com uk6.ibvpn.com uk7.ibvpn.com uk8.ibvpn.com uk9.ibvpn.com uk10.ibvpn.com uk11.ibvpn.com uk12.ibvpn.com uk13.ibvpn.com us1.ibvpn.com us2.ibvpn.com us3.ibvpn.com us4.ibvpn.com us5.ibvpn.com us6.ibvpn.com us7.ibvpn.com us8.ibvpn.com us9.ibvpn.com us10.ibvpn.com us11.ibvpn.com us12.ibvpn.com us13.ibvpn.com us14.ibvpn.com us15.ibvpn.com us16.ibvpn.com us17.ibvpn.com us18.ibvpn.com us19.ibvpn.com us20.ibvpn.com us21.ibvpn.com us22.ibvpn.com us23.ibvpn.com us24.ibvpn.com us25.ibvpn.com vn1.ibvpn.com za1.ibvpn.com nl2sg.ibvpn.com nl2us.ibvpn.com sg2nl.ibvpn.com sg2us.ibvpn.com us2nl.ibvpn.com us2sg.ibvpn.com tornl.ibvpn.com torsg.ibvpn.com torus.ibvpn.com"

## For OpenVPN.
VPN_INTERFACE=tap0

## Destinations you don not want routed through the VPN.
LOCAL_NET="192.168.1.0/24 192.168.0.0/24 127.0.0.0/8"

######################################################################
## DO NOT CHANGE ANYTHING BELOW, UNLESS YOU KNOW WHAT YOU ARE DOING! #
## DO NOT CHANGE ANYTHING BELOW, UNLESS YOU KNOW WHAT YOU ARE DOING! #
## DO NOT CHANGE ANYTHING BELOW, UNLESS YOU KNOW WHAT YOU ARE DOING! #
## DO NOT CHANGE ANYTHING BELOW, UNLESS YOU KNOW WHAT YOU ARE DOING! #
## DO NOT CHANGE ANYTHING BELOW, UNLESS YOU KNOW WHAT YOU ARE DOING! #
######################################################################

###########################
## root check
###########################

if [ "$(id -u)" != "0" ]; then
   echo "FATAL ERROR: This script must be run as root (sudo)!"
   exit 1
fi

###########################
## comments
###########################

## --reject-with
## http://ubuntuforums.....php?p=12011099

## Set to icmp-admin-prohibited because icmp-port-unreachable caused
## confusion. icmp-port-unreachable looks like a bug while
## icmp-admin-prohibited hopefully makes clear it is by design.

###########################

###########################

echo "OK: Loading VPN firewall..."

###########################
## IPv4 DEFAULTS
###########################

## Set secure defaults.
iptables -P INPUT DROP

## FORWARD rules does not actually do anything if forwarding is disabled. Better be safe just in case.
iptables -P FORWARD DROP

## Only the VPN process is allowed to establish outgoing connections.
iptables -P OUTPUT DROP

###########################
## IPv4 PREPARATIONS
###########################

## Flush old rules.
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X

############################
## IPv4 DROP INVALID PACKAGES
############################

## DROP INVALID
iptables -A INPUT -m state --state INVALID -j DROP

## DROP INVALID SYN PACKETS
iptables -A INPUT -p tcp --tcp-flags ALL ACK,RST,SYN,FIN -j DROP
iptables -A INPUT -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP
iptables -A INPUT -p tcp --tcp-flags SYN,RST SYN,RST -j DROP

## DROP PACKETS WITH INCOMING FRAGMENTS. THIS ATTACK ONCE RESULTED IN KERNEL PANICS
iptables -A INPUT -f -j DROP

## DROP INCOMING MALFORMED XMAS PACKETS
iptables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP

## DROP INCOMING MALFORMED NULL PACKETS
iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP

###########################
## IPv4 INPUT
###########################

## Traffic on the loopback interface is accepted.
iptables -A INPUT -i lo -j ACCEPT

## Established incoming connections are accepted.
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

## Allow all incoming connections on the virtual VPN network interface.
iptables -A INPUT -i "$VPN_INTERFACE" -j ACCEPT

## Log.
iptables -A INPUT -j LOG --log-prefix "VPN firewall blocked input4: "

## Reject anything not explicitly allowed above.
## Drop is better than reject here, because ...
iptables -A INPUT -j DROP

###########################
## IPv4 FORWARD
###########################

## Log.
iptables -A FORWARD -j LOG --log-prefix "VPN firewall blocked forward4: "

## Reject everything.
iptables -A FORWARD -j REJECT --reject-with icmp-admin-prohibited

###########################
## IPv4 OUTPUT
###########################

## XXX
iptables -A OUTPUT -o "$VPN_INTERFACE" -j ACCEPT

## XXX
for SERVER in $VPN_SERVERS; do
  iptables -A OUTPUT -d "$SERVER" -j ACCEPT
done

## Existing connections are accepted.
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

## Accept outgoing connections to local network.
for NET in $LOCAL_NET; do
   iptables -A OUTPUT -d "$NET" -j ACCEPT
done

## Log.
iptables -A OUTPUT -j LOG --log-prefix "VPN firewall blocked output4: "

## Reject all other outgoing traffic.
iptables -A OUTPUT -j REJECT --reject-with icmp-admin-prohibited

###########################
## IPv6
###########################

## Policy DROP for all traffic as fallback.
ip6tables -P INPUT DROP
ip6tables -P OUTPUT DROP
ip6tables -P FORWARD DROP

## Flush old rules.
ip6tables -F
ip6tables -X
ip6tables -t mangle -F
ip6tables -t mangle -X
 
## Allow unlimited access on loopback.
## Not activated, since we do not need it.
#ip6tables -A INPUT -i lo -j ACCEPT
#ip6tables -A OUTPUT -o lo -j ACCEPT

## Log.
#ip6tables -A INPUT -j LOG --log-prefix "VPN firewall blocked input6: "
#ip6tables -A OUTPUT -j LOG --log-prefix "VPN firewall blocked output6: "
#ip6tables -A FORWARD -j LOG --log-prefix "VPN firewall blocked forward6: "

## Drop/reject all other traffic.
ip6tables -A INPUT -j DROP
## --reject-with icmp-admin-prohibited not supported by ip6tables
ip6tables -A OUTPUT -j REJECT
## --reject-with icmp-admin-prohibited not supported by ip6tables
ip6tables -A FORWARD -j REJECT

###########################
## End
###########################

echo "OK: The firewall should not show any messages,"
echo "OK: besides output beginning with prefix OK:..."
echo "OK: VPN firewall loaded."

exit 0
 
    
