#!/bin/bash

echo "=== Linux Mint Health Check(advance) ==="
echo "Date: $(date)"
echo "=============================="

# Function to evaluate usage with more granular scale
evaluate() {
    usage=$1
    if (( usage < 50 )); then
        echo "Excellent"
    elif (( usage < 65 )); then
        echo "Good"
    elif (( usage < 75 )); then
        echo "Fair"
    elif (( usage < 85 )); then
        echo "Poor"
    else
        echo "Critical"
    fi
}

# Function to convert rating to score
score() {
    rating=$1
    case $rating in
        Excellent) echo 5 ;;
        Good) echo 4 ;;
        Fair) echo 3 ;;
        Poor) echo 2 ;;
        Critical) echo 1 ;;
    esac
}

# ---------------- CPU ----------------
cpu_load=$(top -bn1 | grep "Cpu(s)" | awk '{print int($2 + $4)}')
cpu_rating=$(evaluate $cpu_load)
echo -e "\n[CPU Usage]"
echo "CPU Load: $cpu_load% - $cpu_rating"

# ---------------- Memory ----------------
mem_total=$(free -h | awk '/Mem:/ {print $2}')
mem_used=$(free -h | awk '/Mem:/ {print $3}')
mem_percent=$(free | awk '/Mem:/ {printf "%.0f", $3/$2*100}')
mem_rating=$(evaluate $mem_percent)

echo -e "\n[Memory Usage]"
echo "Memory Used: $mem_used / $mem_total ($mem_percent%) - $mem_rating"

# ---------------- Disk ----------------
disk_info=$(df -h / | awk 'NR==2 {print $2, $3, $5}')
disk_total=$(echo $disk_info | awk '{print $1}')
disk_used=$(echo $disk_info | awk '{print $2}')
disk_percent=$(echo $disk_info | awk '{print $3}' | sed 's/%//')
disk_rating=$(evaluate $disk_percent)

echo -e "\n[Disk Usage - /]"
echo "Disk Used: $disk_used / $disk_total ($disk_percent%) - $disk_rating"

# ---------------- Overall Health ----------------
cpu_score=$(score $cpu_rating)
mem_score=$(score $mem_rating)
disk_score=$(score $disk_rating)

avg_score=$(( (cpu_score + mem_score + disk_score) / 3 ))

case $avg_score in
    5) overall="Excellent" ;;
    4) overall="Good" ;;
    3) overall="Fair" ;;
    2) overall="Poor" ;;
    1) overall="Critical" ;;
esac

echo -e "\n[Overall Health]"
echo "Overall System Health: $overall"

# Optional TTS
if command -v espeak &> /dev/null; then
    espeak "Overall system health is $overall"
fi

echo -e "\n=== Health Check Complete ==="
