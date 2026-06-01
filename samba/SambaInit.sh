#!/bin/sh
set -e

echo "Inicializando Samba"

# Crear estructura
mkdir -p /mount/desarrollo /mount/revision /mount/publico

for i in 1 2 3 4 5
do
  mkdir -p /mount/desarrollo/SW$i
  mkdir -p /mount/revision/SW$i
  mkdir -p /mount/publico/SW$i
done

echo "Estructura creada"

# Permisos simples (NO usuarios Linux)
chmod -R 0775 /mount/desarrollo
chmod -R 0770 /mount/revision
chmod -R 0555 /mount/publico

echo "Permisos aplicados"

# Samba
exec samba.sh \
  -u "empleado1;pass1" \
  -u "empleado2;pass2" \
  -u "empleado3;pass3" \
  -u "empleado4;pass4" \
  -u "empleado5;pass5" \
  -u "revisor;adminpass" \
  -s "SW1;/mount/desarrollo/SW1;yes;no;no;empleado1" \
  -s "SW2;/mount/desarrollo/SW2;yes;no;no;empleado2" \
  -s "SW3;/mount/desarrollo/SW3;yes;no;no;empleado3" \
  -s "SW4;/mount/desarrollo/SW4;yes;no;no;empleado4" \
  -s "SW5;/mount/desarrollo/SW5;yes;no;no;empleado5" \
  -s "revision;/mount/revision;yes;no;no;empleado1,empleado2,empleado3,empleado4,empleado5,revisor" \
  -s "publico;/mount/publico;yes;no;no;empleado1,empleado2,empleado3,empleado4,empleado5,revisor" \
  -p