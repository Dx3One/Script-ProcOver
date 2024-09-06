#!/bin/bash
DURATION=$((30 * 60)) # 30 Minuten
INTERVAL=10
TEMP_FILE=$(mktemp)
monitor_processes() {
    while true; do
        # Sammle die CPU- und Speicherinformationen der laufenden Prozesse
        ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 20 >> "$TEMP_FILE"
        echo "-----------------------------" >> "$TEMP_FILE"
        sleep "$INTERVAL"
    done
}
monitor_processes &
MONITOR_PID=$!
sleep "$DURATION"
kill "$MONITOR_PID"
echo "Prozesse mit der höchsten Last:"
awk '/%MEM/ {getline} {print $1, $3, $4, $5, $6}' "$TEMP_FILE" | sort -k4 -n -r | uniq -c | sort -n -r | head -n 10
rm -f "$TEMP_FILE"
