#!/bin/bash

# ================================================
# Linux Mint Surface Error Checker
# Checks for common, easily-fixable issues
# Usage: sudo ./surface_errors.sh [--fix] [--tts]
# ================================================

USE_TTS=true
AUTO_FIX=false

for arg in "$@"; do
    case $arg in
        --fix) AUTO_FIX=true ;;
        --tts) USE_TTS=true ;;
    esac
done

ERRORS_FOUND=0
FIXES_APPLIED=0

header() { printf "\n[%s]\n" "$1"; }
ok()     { printf "  OK: %s\n" "$1"; }
warn()   { printf "  WARN: %s\n" "$1"; ERRORS_FOUND=$((ERRORS_FOUND + 1)); }
fix()    { printf "  FIX: %s\n" "$1"; }
fixed()  { printf "  FIXED: %s\n" "$1"; FIXES_APPLIED=$((FIXES_APPLIED + 1)); }

printf "=== Linux Mint Surface Error Check ===\n"
printf "Date: %s\n" "$(date)"
$AUTO_FIX && printf "Mode: AUTO-FIX ON (safe fixes only)\n"
printf "=======================================\n"

# ------------------------------------------------
# 1. Failed systemd services
# ------------------------------------------------
header "Failed Systemd Services"
failed_services=$(systemctl --failed --no-legend 2>/dev/null | awk '{print $1}')
if [ -z "$failed_services" ]; then
    ok "No failed services"
else
    while IFS= read -r svc; do
        warn "Service failed: $svc"
        fix "sudo systemctl restart $svc"
        fix "sudo systemctl status $svc  (to investigate)"
    done <<< "$failed_services"
fi

# ------------------------------------------------
# 2. APT / package issues
# ------------------------------------------------
header "APT / Package Issues"

# Broken packages
broken=$(dpkg -l 2>/dev/null | grep -E '^(iF|iH|iU)' | awk '{print $2}')
if [ -z "$broken" ]; then
    ok "No broken packages"
else
    while IFS= read -r pkg; do
        warn "Broken package: $pkg"
    done <<< "$broken"
    if $AUTO_FIX; then
        printf "  Running: apt --fix-broken install...\n"
        apt --fix-broken install -y 2>&1 | tail -3
        fixed "Attempted fix for broken packages"
    else
        fix "sudo apt --fix-broken install"
    fi
fi

# Held packages — never auto-unhold, user decision
held=$(apt-mark showhold 2>/dev/null)
if [ -n "$held" ]; then
    while IFS= read -r pkg; do
        warn "Held package (won't update): $pkg"
        fix "sudo apt-mark unhold $pkg"
    done <<< "$held"
else
    ok "No held packages"
fi

# Leftover config files from removed packages
leftover=$(dpkg -l 2>/dev/null | grep '^rc' | awk '{print $2}')
if [ -n "$leftover" ]; then
    count=$(echo "$leftover" | wc -l)
    warn "$count leftover config(s) from removed packages"
    if $AUTO_FIX; then
        printf "  Running: dpkg --purge on leftover configs...\n"
        echo "$leftover" | xargs dpkg --purge 2>&1 | tail -3
        fixed "Purged $count leftover package config(s)"
    else
        fix "sudo dpkg --purge \$(dpkg -l | grep '^rc' | awk '{print \$2}')"
    fi
else
    ok "No leftover package configs"
fi

# APT cache — safe to clean automatically
header "APT Cache"
if $AUTO_FIX; then
    printf "  Running: apt autoremove && apt clean...\n"
    apt autoremove -y 2>&1 | tail -2
    apt clean 2>&1
    fixed "APT cache cleaned and orphan packages removed"
else
    orphans=$(apt-get --dry-run autoremove 2>/dev/null | grep '^Remv' | wc -l)
    if (( orphans > 0 )); then
        warn "$orphans orphan package(s) can be removed"
        fix "sudo apt autoremove && sudo apt clean"
    else
        ok "No orphan packages"
    fi
fi

# ------------------------------------------------
# 3. Disk space (all mounted filesystems)
# ------------------------------------------------
header "Disk Space"
while IFS= read -r line; do
    mount=$(echo "$line" | awk '{print $6}')
    percent=$(echo "$line" | awk '{print $5}' | sed 's/%//')
    if (( percent >= 90 )); then
        warn "Disk $mount is ${percent}% full — critical"
        fix "du -sh $mount/* 2>/dev/null | sort -rh | head -10"
    elif (( percent >= 75 )); then
        warn "Disk $mount is ${percent}% full — getting tight"
        fix "sudo apt autoremove && sudo apt clean"
    else
        ok "Disk $mount: ${percent}% used"
    fi
done < <(df -h --output=source,size,used,avail,pcent,target | tail -n +2 | grep -v tmpfs | grep -v udev)

# ------------------------------------------------
# 4. Pending reboot
# ------------------------------------------------
header "Pending Reboot"
if [ -f /var/run/reboot-required ]; then
    warn "Reboot required"
    if [ -f /var/run/reboot-required.pkgs ]; then
        fix "Caused by: $(cat /var/run/reboot-required.pkgs | tr '\n' ' ')"
    fi
    fix "sudo reboot  (when ready)"
else
    ok "No reboot required"
fi

# ------------------------------------------------
# 5. Critical log errors (last 24h)
# ------------------------------------------------
header "Critical System Log Errors (last 24h)"
if command -v journalctl &>/dev/null; then
    crit_errors=$(journalctl -p 0..2 --since "24 hours ago" --no-pager -q 2>/dev/null | head -20)
    if [ -z "$crit_errors" ]; then
        ok "No emergency/alert/critical entries in journal"
    else
        warn "Critical log entries found:"
        echo "$crit_errors" | while IFS= read -r line; do
            printf "    %s\n" "$line"
        done
        fix "journalctl -p 0..2 --since '24 hours ago' --no-pager  (full view)"
    fi
else
    if [ -f /var/log/syslog ]; then
        crit=$(grep -iE '\b(error|critical|fail)\b' /var/log/syslog | tail -10)
        if [ -z "$crit" ]; then
            ok "No obvious errors in /var/log/syslog"
        else
            warn "Possible errors in syslog (last 10):"
            echo "$crit" | while IFS= read -r line; do
                printf "    %s\n" "$line"
            done
        fi
    fi
fi

# ------------------------------------------------
# 6. Broken symlinks in common dirs
# ------------------------------------------------
header "Broken Symlinks"
broken_links=""
for dir in /usr/bin /usr/lib /etc; do
    found=$(find "$dir" -maxdepth 2 -xtype l 2>/dev/null)
    broken_links="$broken_links$found"$'\n'
done

broken_links=$(echo "$broken_links" | sed '/^\s*$/d')
if [ -z "$broken_links" ]; then
    ok "No broken symlinks found in /usr/bin, /usr/lib, /etc"
else
    count=$(echo "$broken_links" | wc -l)
    warn "$count broken symlink(s) found"
    echo "$broken_links" | while IFS= read -r link; do
        printf "    %s\n" "$link"
    done
    fix "Investigate before deleting — likely leftover from uninstalled packages."
fi

# ------------------------------------------------
# Summary
# ------------------------------------------------
printf "\n=======================================\n"
if (( ERRORS_FOUND == 0 )); then
    printf "Result: No issues found.\n"
else
    printf "Result: %d issue(s) found.\n" "$ERRORS_FOUND"
    if $AUTO_FIX; then
        printf "        %d fix(es) applied automatically.\n" "$FIXES_APPLIED"
        remaining=$(( ERRORS_FOUND - FIXES_APPLIED ))
        (( remaining > 0 )) && printf "        %d remaining require manual action.\n" "$remaining"
    else
        printf "        Run with --fix to auto-resolve safe issues.\n"
    fi
fi
printf "=== Check Complete ===\n"
if $USE_TTS; then
    if command -v edge-tts &>/dev/null && command -v mpv &>/dev/null; then
        if (( ERRORS_FOUND == 0 )); then
            edge-tts --voice "en-US-EricNeural" --text "No issues found. System looks clean." | mpv --no-terminal -
        else
            edge-tts --voice "en-US-EricNeural" --text "$ERRORS_FOUND issues found. $FIXES_APPLIED fixed automatically." | mpv --no-terminal -
        fi
    else
        printf "[TTS] edge-tts or mpv not installed.\n"
    fi
fi