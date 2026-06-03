#!/bin/bash
set -e

apt update
apt install -y postfix dovecot-imapd mailutils
echo "empresa.local" > /etc/mailname

postconf -e "myhostname = mail.empresa.local"
postconf -e "mydomain = empresa.local"
postconf -e "myorigin = \$mydomain"
postconf -e "inet_interfaces = all"
postconf -e "mydestination = \$myhostname, localhost, \$mydomain"
postconf -e "mynetworks = 127.0.0.0/8"
postconf -e "relay_domains ="
postconf -e "home_mailbox = Maildir/"
postconf -e "smtpd_relay_restrictions = permit_mynetworks,reject_unauth_destination"
postconf -e "smtpd_recipient_restrictions = permit_mynetworks,reject_unauth_destination"

id usuario1 >/dev/null 2>&1 || useradd -m usuario1
echo "usuario1:correo1" | chpasswd

id usuario2 >/dev/null 2>&1 || useradd -m usuario2
echo "usuario2:correo2" | chpasswd

id usuario3 >/dev/null 2>&1 || useradd -m usuario3
echo "usuario3:correo3" | chpasswd

mkdir -p /home/usuario1/Maildir/{cur,new,tmp}
chown -R usuario1:usuario1 /home/usuario1/Maildir

mkdir -p /home/usuario2/Maildir/{cur,new,tmp}
chown -R usuario2:usuario2 /home/usuario2/Maildir

mkdir -p /home/usuario3/Maildir/{cur,new,tmp}
chown -R usuario3:usuario3 /home/usuario3/Maildir

sed -i 's|^#mail_location =.*|mail_location = maildir:~/Maildir|' \
/etc/dovecot/conf.d/10-mail.conf

service postfix restart
service dovecot restart

echo "Servidor de correo iniciado."

tail -f /dev/null