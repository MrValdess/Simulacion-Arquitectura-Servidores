#!/bin/sh

apk add --no-cache iptables iproute2

echo "[+] Detectando interfaces..."

DEV_NET="172.40.0.0/24"
PROD_NET="172.30.0.0/24"
SVC_NET="172.20.0.0/24"
DNS_IP="172.20.0.6"

echo "[+] Limpiando reglas..."
iptables -F
iptables -t nat -F 2>/dev/null
iptables -X 2>/dev/null

echo "[+] Políticas por defecto..."
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

echo "[+] Loopback + conexiones establecidas..."
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT


# Forward DNS 
echo "[+] Permitir DNS hacia Bind9..."
iptables -A FORWARD -s $DEV_NET -d $DNS_IP -p udp --dport 53 -j ACCEPT
iptables -A FORWARD -s $DEV_NET -d $DNS_IP -p tcp --dport 53 -j ACCEPT

iptables -A FORWARD -s $PROD_NET -d $DNS_IP -p udp --dport 53 -j ACCEPT
iptables -A FORWARD -s $PROD_NET -d $DNS_IP -p tcp --dport 53 -j ACCEPT

# Retorno DNS
iptables -A FORWARD -s $DNS_IP -d $DEV_NET -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -s $DNS_IP -d $PROD_NET -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -s $DEV_NET -d $SVC_NET -p tcp -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -s $PROD_NET -d $SVC_NET -p tcp -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -s $SVC_NET -d $DEV_NET -p tcp -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -s $SVC_NET -d $PROD_NET -p tcp -m state --state ESTABLISHED,RELATED -j ACCEPT


# Servicios
echo "[+] Acceso a red de servicios..."
iptables -A FORWARD -s $DEV_NET -d $SVC_NET -j ACCEPT
iptables -A FORWARD -s $PROD_NET -d $SVC_NET -j ACCEPT
iptables -A FORWARD -s $SVC_NET -d $DEV_NET -j ACCEPT
iptables -A FORWARD -s $SVC_NET -d $PROD_NET -j ACCEPT


# Dev y Prod aislados
echo "[+] Bloqueo DEV ↔ PROD..."
iptables -A FORWARD -s $DEV_NET -d $PROD_NET -j DROP
iptables -A FORWARD -s $PROD_NET -d $DEV_NET -j DROP

# Internet
echo "[+] Salida HTTP/HTTPS..."
iptables -A OUTPUT -p tcp --dport 80 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT

# Pruebas PING
echo "[+] Permitir ICMP (ping para testing)..."
iptables -A FORWARD -p icmp -j ACCEPT

# Docker network
echo "[+] Red interna Docker segura..."
iptables -A FORWARD -s 172.0.0.0/8 -d 172.0.0.0/8 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT


echo "[+] Firewall activo correctamente"

tail -f /dev/null