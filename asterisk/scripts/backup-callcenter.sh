#!/bin/bash
# backup-callcenter.sh
# Backup diario de base de datos y grabaciones

DATE=$(date +%Y%m%d)
BACKUP_DIR="/backups"

# Backup de base de datos
docker exec callcenter_db mysqldump -u root -p$DB_ROOT_PASSWORD suitecrm > $BACKUP_DIR/suitecrm-$DATE.sql

# Backup de grabaciones (últimos 30 días)
tar -czf $BACKUP_DIR/recordings-$DATE.tar.gz /var/lib/docker/volumes/callcenter_asterisk_recordings

# Subir a Oracle Object Storage (gratis 10GB)
# oci os object put --bucket-name callcenter-backups --file $BACKUP_DIR/suitecrm-$DATE.sql

# Limpiar backups locales > 7 días
find $BACKUP_DIR -name "*.sql" -mtime +7 -delete
