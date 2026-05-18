#!/bin/sh
set -e

OVPN_DIR="/etc/openvpn"

echo "[*] Instalando dependencias..."
apk add --no-cache bash iproute2 iputils

echo "[*] Configurando rutas de red..."

ip route del default 2>/dev/null
ip route add default via 172.10.0.2

echo "[+] Iniciando contenedor OpenVPN..."

# Inicialización 
if [ ! -f "$OVPN_DIR/openvpn.conf" ]; then
    echo "[+] Primera ejecución: generando configuración..."

    ovpn_genconfig -u udp://localhost
    echo "[+] Generando PKI..."
    EASYRSA_BATCH=1 ovpn_initpki nopass
fi

# Clientes y creacion de usuarios
mkdir -p "$OVPN_DIR/clients"

if [ ! -f "$OVPN_DIR/pki/private/dev_user.key" ]; then
    echo "[+] Creando usuario de desarrollo..."
    easyrsa build-client-full dev_user nopass
fi

if [ ! -f "$OVPN_DIR/pki/private/svc_prod_user.key" ]; then
    echo "[+] Creando usuario de servicios..."
    easyrsa build-client-full svc_prod_user nopass
fi

# Exportar a local
echo "[+] Exportando clientes..."

ovpn_getclient dev_user > "$OVPN_DIR/clients/dev_user.ovpn"
ovpn_getclient svc_prod_user > "$OVPN_DIR/clients/svc_prod_user.ovpn"

echo "[+] Arrancando servidor OpenVPN..."
exec ovpn_run