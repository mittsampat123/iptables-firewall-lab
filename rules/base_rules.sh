#!/bin/bash

echo "Configuring base iptables rules..."

iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X

iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

iptables -A INPUT -p icmp --icmp-type echo-request -m limit --limit 1/s --limit-burst 4 -j ACCEPT
iptables -A INPUT -p icmp --icmp-type echo-request -j DROP

iptables -A INPUT -p tcp --dport 22 -m state --state NEW -m limit --limit 2/minute --limit-burst 3 -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -j DROP

iptables -A INPUT -p tcp --dport 80 -m state --state NEW -m limit --limit 25/minute --limit-burst 100 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -m state --state NEW -m limit --limit 25/minute --limit-burst 100 -j ACCEPT

iptables -A INPUT -p tcp --dport 53 -j ACCEPT
iptables -A INPUT -p udp --dport 53 -j ACCEPT

iptables -A INPUT -p tcp --dport 123 -j ACCEPT
iptables -A INPUT -p udp --dport 123 -j ACCEPT

iptables -A INPUT -j LOG --log-prefix "IPTABLES-DROPPED: "
iptables -A INPUT -j DROP

iptables -A FORWARD -j LOG --log-prefix "IPTABLES-FORWARD-DROPPED: "
iptables -A FORWARD -j DROP

echo "Base iptables rules configured successfully"
