#!/bin/bash

apt update
apt install -y vsftpd

cat > /etc/vsftpd.conf << EOF
listen=YES

anonymous_enable=YES
no_anon_password=YES

local_enable=NO

write_enable=NO
anon_upload_enable=NO
anon_mkdir_write_enable=NO

anon_root=/ftp/publico

pasv_enable=YES
pasv_min_port=30000
pasv_max_port=30000

xferlog_enable=YES
EOF

mkdir -p /var/run/vsftpd/empty

/usr/sbin/vsftpd /etc/vsftpd.conf

tail -f /dev/null