#!/bin/sh

# Instalar iptables en Alpine
apk add --no-cache iptables

#!/bin/sh

echo "[+] Detectando interfaces..."

# Obtener interfaces por subred
DEV_IF=$(ip -o -4 addr show | grep "172.40.0." | awk '{print $2}')
PROD_IF=$(ip -o -4 addr show | grep "172.30.0." | awk '{print $2}')
SVC_IF=$(ip -o -4 addr show | grep "172.20.0." | awk '{print $2}')

echo "DEV_IF=$DEV_IF"
echo "PROD_IF=$PROD_IF"
echo "SVC_IF=$SVC_IF"

# Activar forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward

# Limpiar reglas
iptables -F
iptables -t nat -F
iptables -X

# Políticas por defecto
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Loopback
iptables -A INPUT -i lo -j ACCEPT

#TCP y UDP
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT
iptables -A FORWARD -p udp --dport 53 -j ACCEPT
iptables -A FORWARD -p tcp --dport 53 -j ACCEPT

# Tráfico establecido
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT

# FORWARD ENTRE REDES

# dev <-> prod
iptables -A FORWARD -i $DEV_IF -o $PROD_IF -j ACCEPT
iptables -A FORWARD -i $PROD_IF -o $DEV_IF -j ACCEPT

# dev <-> services
iptables -A FORWARD -i $DEV_IF -o $SVC_IF -j ACCEPT
iptables -A FORWARD -i $SVC_IF -o $DEV_IF -j ACCEPT

# prod <-> services
iptables -A FORWARD -i $PROD_IF -o $SVC_IF -j ACCEPT
iptables -A FORWARD -i $SVC_IF -o $PROD_IF -j ACCEPT

echo "[+] Firewall configurado dinámicamente"

tail -f /dev/null