#!/bin/sh

apk add --no-cache iptables iproute2 bash

echo "[*] Iniciando reglas de firewall..."
iptables -P FORWARD DROP
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

echo "[*] Reglas de DNS..."
iptables -A FORWARD -s 172.40.0.0/24 -d 172.20.0.6 -p udp --dport 53 -j ACCEPT
iptables -A FORWARD -s 172.20.0.6 -d 172.40.0.0/24 -p udp --sport 53 -j ACCEPT
iptables -A FORWARD -s 172.30.0.0/24 -d 172.20.0.6 -p udp --dport 53 -j ACCEPT
iptables -A FORWARD -s 172.20.0.6 -d 172.30.0.0/24 -p udp --sport 53 -j ACCEPT

echo "[*] Tráfico entre BDS y SVC..."
iptables -A FORWARD -s 172.30.0.0/24 -d 172.20.0.0/24 -p tcp -m multiport --dports 5432,3306 -j ACCEPT
iptables -A FORWARD -s 172.40.0.0/24 -d 172.20.0.0/24 -p tcp -m multiport --dports 5432,3306 -j ACCEPT

echo "[*] Tráfico entre DEV y SVC..."
iptables -A FORWARD -s 172.20.0.0/24 -d 172.40.0.0/24 -j ACCEPT
iptables -A FORWARD -s 172.40.0.0/24 -d 172.20.0.0/24 -j ACCEPT

echo "[*] Tráfico entre PROD y DEV..."
iptables -A FORWARD -s 172.30.0.0/24 -d 172.40.0.0/24 -j ACCEPT
iptables -A FORWARD -s 172.40.0.0/24 -d 172.30.0.0/24 -j ACCEPT

echo "[*] Bloqueo entre PROD y SVC..."
iptables -A FORWARD -s 172.30.0.0/24 -d 172.20.0.0/24 -j DROP
iptables -A FORWARD -s 172.20.0.0/24 -d 172.30.0.0/24 -j DROP

echo "[*] Reglas de VPN..."
# Usuario 1
iptables -A FORWARD -s 172.10.0.100 -d 172.40.0.0/24 -j ACCEPT
iptables -A FORWARD -s 172.40.0.0/24 -d 172.10.0.100 -j ACCEPT

# Usuario 2
iptables -A FORWARD -s 172.10.0.101 -d 172.30.0.0/24 -j ACCEPT
iptables -A FORWARD -s 172.30.0.0/24 -d 172.10.0.101 -j ACCEPT

iptables -L FORWARD -v --line-numbers

echo "[+] Firewall activo"

tail -f /dev/null