#!/bin/sh

apk add --no-cache iptables iproute2

echo "[+] Detectando interfaces..."

DEV_IF=$(ip -o -4 addr show | grep "172.40.0." | awk '{print $2}' | head -n1)
PROD_IF=$(ip -o -4 addr show | grep "172.30.0." | awk '{print $2}' | head -n1)
SVC_IF=$(ip -o -4 addr show | grep "172.20.0." | awk '{print $2}' | head -n1)

echo "DEV_IF=$DEV_IF"
echo "PROD_IF=$PROD_IF"
echo "SVC_IF=$SVC_IF"

echo "[+] Limpiando reglas..."
iptables -F
iptables -t nat -F 2>/dev/null
iptables -X 2>/dev/null

echo "[+] Políticas por defecto..."
iptables -P INPUT DROP
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

echo "[+] Loopback + conexiones establecidas..."
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

echo "[+] Permitir tráfico entre redes Docker..."
iptables -A FORWARD -i $DEV_IF -o $PROD_IF -j ACCEPT
iptables -A FORWARD -i $PROD_IF -o $DEV_IF -j ACCEPT

iptables -A FORWARD -i $DEV_IF -o $SVC_IF -j ACCEPT
iptables -A FORWARD -i $SVC_IF -o $DEV_IF -j ACCEPT

iptables -A FORWARD -i $PROD_IF -o $SVC_IF -j ACCEPT
iptables -A FORWARD -i $SVC_IF -o $PROD_IF -j ACCEPT

echo "[+] DNS hacia BIND (172.20.0.6)..."
iptables -A OUTPUT -p udp -d 172.20.0.6 --dport 53 -j ACCEPT
iptables -A OUTPUT -p tcp -d 172.20.0.6 --dport 53 -j ACCEPT

echo "[+] DNS general Docker..."
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 53 -j ACCEPT

echo "[+] HTTP/HTTPS salida (CRÍTICO para Composer/cURL)..."
iptables -A OUTPUT -p tcp --dport 80 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT

echo "[+] Red Docker interna (fallback importante)..."
iptables -A FORWARD -s 172.0.0.0/8 -d 172.0.0.0/8 -j ACCEPT

echo "[+] Firewall listo"

tail -f /dev/null