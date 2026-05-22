#!/bin/bash

# ================================================
# Linux Mint Advanced Health Check
# ================================================

USE_TTS=true

# Parse flags
for arg in "$@"; do
    case $arg in
        --tts) USE_TTS=true ;;
    esac
done

# ------------------------------------------------
# Helpers
# ------------------------------------------------

evaluate() {
    local usage=$1
    if   (( usage < 50 )); then echo "Excellent"
    elif (( usage < 65 )); then echo "Good"
    elif (( usage < 75 )); then echo "Fair"
    elif (( usage < 85 )); then echo "Poor"
    else                        echo "Critical"
    fi
}

score() {
    case $1 in
        Excellent) echo 5 ;;
        Good)      echo 4 ;;
        Fair)      echo 3 ;;
        Poor)      echo 2 ;;
        Critical)  echo 1 ;;
        *)         echo 0 ;;
    esac
}

label_from_score() {
    # Uses float score rounded to nearest int
    local fscore=$1
    local rounded
    rounded=$(printf "%.0f" "$fscore")
    case $rounded in
        5) echo "Excellent" ;;
        4) echo "Good" ;;
        3) echo "Fair" ;;
        2) echo "Poor" ;;
        1) echo "Critical" ;;
        *) echo "Unknown" ;;
    esac
}

# ------------------------------------------------
# CPU — sampled over 1 second via /proc/stat
# ------------------------------------------------
read_cpu() {
    grep '^cpu ' /proc/stat
}

cpu_line1=$(read_cpu); sleep 1; cpu_line2=$(read_cpu)

cpu_load=$(awk -v l1="$cpu_line1" -v l2="$cpu_line2" 'BEGIN {
    split(l1, a); split(l2, b)
    idle1 = a[5]; total1 = 0; for (i=2;i<=8;i++) total1 += a[i]
    idle2 = b[5]; total2 = 0; for (i=2;i<=8;i++) total2 += b[i]
    diff_total = total2 - total1
    diff_idle  = idle2  - idle1
    if (diff_total > 0)
        printf "%d", (diff_total - diff_idle) / diff_total * 100
    else
        print 0
}')

cpu_rating=$(evaluate "$cpu_load")

# ------------------------------------------------
# Memory
# ------------------------------------------------
read -r mem_total_kb mem_used_kb <<< "$(awk '/Mem:/ {print $2, $3}' /proc/meminfo 2>/dev/null || \
    free | awk '/Mem:/ {print $2, $3}')"

mem_percent=$(awk "BEGIN {printf \"%d\", $mem_used_kb / $mem_total_kb * 100}")
mem_total_h=$(awk "BEGIN {printf \"%.1fG\", $mem_total_kb / 1048576}")
mem_used_h=$(awk "BEGIN {printf \"%.1fG\", $mem_used_kb / 1048576}")
mem_rating=$(evaluate "$mem_percent")

# ------------------------------------------------
# Swap
# ------------------------------------------------
swap_info=$(free | awk '/Swap:/ {print $2, $3}')
swap_total_kb=$(echo "$swap_info" | awk '{print $1}')
swap_used_kb=$(echo "$swap_info"  | awk '{print $2}')

if (( swap_total_kb > 0 )); then
    swap_percent=$(awk "BEGIN {printf \"%d\", $swap_used_kb / $swap_total_kb * 100}")
    swap_total_h=$(awk "BEGIN {printf \"%.1fG\", $swap_total_kb / 1048576}")
    swap_used_h=$(awk "BEGIN {printf \"%.1fG\", $swap_used_kb / 1048576}")
    swap_rating=$(evaluate "$swap_percent")
    swap_display="Swap Used: $swap_used_h / $swap_total_h ($swap_percent%) - $swap_rating"
else
    swap_percent=0
    swap_rating="Excellent"
    swap_display="Swap: not configured"
fi

# ------------------------------------------------
# Disk
# ------------------------------------------------
read -r disk_total disk_used disk_percent_raw <<< "$(df / | awk 'NR==2 {print $2, $3, $5}')"
disk_percent="${disk_percent_raw//%/}"
disk_total_h=$(awk "BEGIN {printf \"%.1fG\", $disk_total / 1048576}")
disk_used_h=$(awk "BEGIN {printf \"%.1fG\", $disk_used / 1048576}")
disk_rating=$(evaluate "$disk_percent")

# ------------------------------------------------
# Overall — float average to avoid int division loss
# ------------------------------------------------
cpu_s=$(score "$cpu_rating")
mem_s=$(score "$mem_rating")
swap_s=$(score "$swap_rating")
disk_s=$(score "$disk_rating")

avg_score=$(awk "BEGIN {printf \"%.2f\", ($cpu_s + $mem_s + $swap_s + $disk_s) / 4}")
overall=$(label_from_score "$avg_score")

# ------------------------------------------------
# Output
# ------------------------------------------------
printf "\n=== Linux Mint Health Check ===\n"
printf "Date: %s\n" "$(date)"
printf "================================\n"

printf "\n[CPU Usage]\n"
printf "CPU Load: %s%% - %s\n" "$cpu_load" "$cpu_rating"

printf "\n[Memory Usage]\n"
printf "Memory Used: %s / %s (%s%%) - %s\n" "$mem_used_h" "$mem_total_h" "$mem_percent" "$mem_rating"

printf "\n[Swap Usage]\n"
printf "%s\n" "$swap_display"

printf "\n[Disk Usage - /]\n"
printf "Disk Used: %s / %s (%s%%) - %s\n" "$disk_used_h" "$disk_total_h" "$disk_percent" "$disk_rating"

printf "\n[Overall Health]\n"
printf "Score: %s/5.00 → %s\n" "$avg_score" "$overall"

printf "\n=== Health Check Complete ===\n"

# ------------------------------------------------
# Optional TTS (opt-in via --tts flag)
# ------------------------------------------------
if $USE_TTS; then
    if command -v edge-tts &> /dev/null; then

		edge-tts --voice "ru-RU-DmitryNeural" --text "Overall system health is $overall" | mpv --no-terminal -
    else
        printf "[TTS] festival not installed.\n"
    fi
fi