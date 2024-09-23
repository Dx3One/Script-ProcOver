#!/bin/bash
read -p "Wie lange möchtest du die Prozesse überwachen? (in Minuten): " DURATION_MINUTES
DURATION=$((DURATION_MINUTES * 60))
INTERVAL=10
HOSTNAME=$(hostname)
OUTPUT_FILE="pocmon-$HOSTNAME"
TEMP_FILE=$(mktemp)
monitor_processes() {
    while true; do
        ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 20 >> "$TEMP_FILE"
        echo "-----------------------------" >> "$TEMP_FILE"
        sleep "$INTERVAL"
    done
}
monitor_processes &
MONITOR_PID=$!
sleep "$DURATION"
kill "$MONITOR_PID"
echo "Prozesse mit der höchsten Last:" >> "$OUTPUT_FILE"
awk '/%MEM/ {getline} {print $1, $3, $4, $5, $6}' "$TEMP_FILE" | sort -k4 -n -r | uniq -c | sort -n -r | head -n 10 >> "$OUTPUT_FILE"
rm -f "$TEMP_FILE"
echo "Output wurde in der Datei $OUTPUT_FILE gespeichert."
