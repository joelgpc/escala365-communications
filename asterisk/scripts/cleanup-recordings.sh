#!/bin/bash
# cleanup-recordings.sh
# Elimina grabaciones antiguas según política de retención RGPD

# Eliminar grabaciones > 90 días (ajustar según política)
find /var/lib/docker/volumes/callcenter_asterisk_recordings/_data -name "*.wav" -mtime +90 -delete

# Loguear acción para auditoría
echo "$(date): Limpieza de grabaciones antiguas completada" >> /var/log/gdpr-cleanup.log
