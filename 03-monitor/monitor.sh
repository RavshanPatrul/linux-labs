#!/bin/bash
# monitor.sh — мониторинг процессов: раз в INTERVAL секунд дописывает
# снимок самых нагруженных процессов в processes.log.
# Использование: monitor.sh [число_снимков]   (без аргумента — бесконечно)

INTERVAL=5
LOG=/home/zatpe/monitor/processes.log
COUNT=${1:-0}            # 0 = работать бесконечно (режим службы)

snapshot() {
    {
        echo "===== $(date '+%Y-%m-%d %H:%M:%S') | процессов: $(ps -e --no-headers | wc -l) | load: $(cut -d' ' -f1-3 /proc/loadavg)"
        ps -eo pid,user,%cpu,%mem,etime,comm --sort=-%cpu | head -11
    } >> "$LOG"
}

n=0
while :; do
    snapshot
    n=$((n + 1))
    [ "$COUNT" -gt 0 ] && [ "$n" -ge "$COUNT" ] && break
    sleep "$INTERVAL"
done
