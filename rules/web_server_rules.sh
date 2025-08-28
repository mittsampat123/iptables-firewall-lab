#!/bin/bash

echo "Configuring web server iptables rules..."

iptables -N WEB_SERVER
iptables -A INPUT -p tcp --dport 80 -j WEB_SERVER
iptables -A INPUT -p tcp --dport 443 -j WEB_SERVER

iptables -A WEB_SERVER -m state --state NEW -m limit --limit 30/minute --limit-burst 50 -j ACCEPT
iptables -A WEB_SERVER -m state --state ESTABLISHED,RELATED -j ACCEPT

iptables -A WEB_SERVER -p tcp --tcp-flags ALL NONE -j DROP
iptables -A WEB_SERVER -p tcp --tcp-flags ALL ALL -j DROP
iptables -A WEB_SERVER -p tcp --tcp-flags ALL FIN,PSH,URG -j DROP
iptables -A WEB_SERVER -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -j DROP
iptables -A WEB_SERVER -p tcp --tcp-flags SYN,RST SYN,RST -j DROP
iptables -A WEB_SERVER -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP

iptables -A WEB_SERVER -m limit --limit 1/minute --limit-burst 10 -j LOG --log-prefix "WEB-ATTACK: "
iptables -A WEB_SERVER -j DROP

echo "Web server iptables rules configured successfully"
