#!/bin/bash
# Memory Check Script — Human Readable Output
# Alerts if usage exceeds 90%
echo "|=====================|"
echo "|Author: Shafique Khan|"
echo "|Date: 01-Jun-2026 v1 |"
echo "======================"
## ── Gather raw memory info ──────────────────────────────
declare -A MEM

while IFS=":" read -r key val; do
  name=$(echo "$key" | tr -d ' ')
  kb=$(echo "$val"  | awk '{print $1}')
  MEM["$name"]=$kb
done < /proc/meminfo

## ── Convert KB → human readable ─────────────────────────
human() {
  local kb=$1
  if   [[ $kb -ge 1048576 ]]; then
    awk "BEGIN {printf \"%.1f GiB\", $kb/1048576}"
  elif [[ $kb -ge 1024    ]]; then
    awk "BEGIN {printf \"%.1f MiB\", $kb/1024}"
  else
    echo "${kb} KiB"
  fi
}

## ── Pull values from array ───────────────────────────────
TOTAL=${MEM[MemTotal]}
AVAILABLE=${MEM[MemAvailable]:-0}
BUFFERS=${MEM[Buffers]}
CACHED=${MEM[Cached]}
SWAP_TOTAL=${MEM[SwapTotal]}
SWAP_FREE=${MEM[SwapFree]}

USED=$(( TOTAL - AVAILABLE ))
PUSED=$(( USED  * 100 / TOTAL ))
PFREE=$(( 100   - PUSED ))

SWAP_USED=$(( SWAP_TOTAL - SWAP_FREE ))
[[ $SWAP_TOTAL -gt 0 ]] && PSWAP=$(( SWAP_USED * 100 / SWAP_TOTAL )) || PSWAP=0

## ── Display ──────────────────────────────────────────────
BORDER="──────────────────────────────────────────"
printf "\n%s\n"             "$BORDER"
printf "  Memory Report  ·  %s\n" "$(date '+%Y-%m-%d %H:%M:%S')"
printf "%s\n"              "$BORDER"

printf "  %-12s %10s\n"          "Total:"     "$(human $TOTAL)"
printf "  %-12s %10s  (%d%%)\n"   "Used:"      "$(human $USED)"      $PUSED
printf "  %-12s %10s  (%d%%)\n"   "Available:" "$(human $AVAILABLE)" $PFREE
printf "  %-12s %10s\n"          "Buffers:"   "$(human $BUFFERS)"
printf "  %-12s %10s\n"          "Cached:"    "$(human $CACHED)"

printf "\n  %-12s %10s  (%d%% used)\n" "Swap:" \
  "$(human $SWAP_USED) / $(human $SWAP_TOTAL)" $PSWAP

printf "%s\n\n" "$BORDER"

## ── Alert (You can change this to test if script is working fine by adusting the threshold) ────────────────────────────────────────────────
THRESHOLD=90

if [[ $PUSED -ge $THRESHOLD ]]; then
  printf "  ⚠️  ALERT: Memory usage is %d%% — above %d%% threshold!\n" \
    $PUSED $THRESHOLD
  printf "  ✦  Only %s available.\n\n" "$(human $AVAILABLE)"
  exit 1
else
  printf "  ✔️  Memory OK (%d%% used, threshold %d%%)\n\n" \
    $PUSED $THRESHOLD
fi
