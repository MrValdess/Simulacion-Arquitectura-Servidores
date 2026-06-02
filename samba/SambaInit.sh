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

# Permisos desarrollo (aislamiento por share)
chmod -R 0775 /mount/desarrollo

# revisión (todos pueden escribir)
chmod -R 0770 /mount/revision

# público (lectura general)
chmod -R 0755 /mount/publico

chmod -R a-w /mount/publico
if command -v setfacl >/dev/null 2>&1; then
  setfacl -R -m u:revisor:rwx /mount/publico
fi

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
  -s "revision;/mount/revision;yes;no;no;empleado1,empleado2,empleado3,empleado4,empleado5,revisor;revisor;revisor" \
  -s "publico;/mount/publico;yes;yes;no;empleado1,empleado2,empleado3,empleado4,empleado5,revisor;;revisor" \
  -p