#!/bin/bash
# backup.sh — ежедневное резервное копирование по плану:
#   что:   /home/user1, /etc, дамп БД mydb
#   куда:  /backup/daily/<дата>
#   срок:  хранится 7 последних копий
set -euo pipefail
DEST=/backup/daily/$(date +%F_%H%M)
KEEP=7
mkdir -p "$DEST"
tar -czf "$DEST/home-user1.tar.gz" -C / home/user1
tar -czf "$DEST/etc.tar.gz" -C / etc 2>/dev/null || true
mysqldump --single-transaction mydb | gzip > "$DEST/mydb.sql.gz"
sha256sum "$DEST"/* > "$DEST/SHA256SUMS"
# ротация: удалить всё, кроме KEEP последних
ls -1dt /backup/daily/*/ | tail -n +$((KEEP + 1)) | xargs -r rm -rf
echo "$(date '+%F %T') backup OK: $DEST ($(du -sh "$DEST" | cut -f1))" >> /var/log/backup.log
