#!/bin/bash
# Check status of multiple services using is-active
# Usage:  ./service_check.sh
#         ./service_check.sh nginx mysql redis
echo "================================================="
echo "Author: Shafique Khan, Created on: 01-Jun-2026 v2"
echo "================================================="

SERVICES=(
  nginx
  mysql
  redis
  docker
  sshd
  cron
)

if [[ $# -gt 0 ]]; then
  SERVICES=("$@")
fi

TOTAL=0
PASS=0
FAIL=0
FAILED_LIST=()

BORDER="──────────────────────────────────────────────"
printf "\n%s\n"                   "$BORDER"
printf "  Service Status Check  ·  %s\n" "$(date '+%Y-%m-%d %H:%M:%S')"
printf "%s\n\n"                  "$BORDER"

for svc in "${SERVICES[@]}"; do
  STATUS=$(systemctl is-active "$svc" 2>&1)
  (( TOTAL++ ))

  case "$STATUS" in
    active)
      printf "  [ ✔️ ]  %-25s %s\n" "$svc" "active"
      (( PASS++ ))
      ;;
    inactive)
      printf "  [ ✘ ]  %-25s %s\n" "$svc" "inactive"
      (( FAIL++ ))
      FAILED_LIST+=("$svc")
      ;;
    failed)
      printf "  [ ✘ ]  %-25s %s\n" "$svc" "FAILED"
      (( FAIL++ ))
      FAILED_LIST+=("$svc")
      ;;
    *)
      printf "  [ ? ]  %-25s %s\n" "$svc" "$STATUS (not found?)"
      (( FAIL++ ))
      FAILED_LIST+=("$svc")
      ;;
  esac
done

printf "\n%s\n" "$BORDER"
printf "  Total: %d  |  Active: %d  |  Not active: %d\n" \
  $TOTAL $PASS $FAIL

if [[ ${#FAILED_LIST[@]} -gt 0 ]]; then
  printf "\n  ⚠️  Not running: %s\n" \
    "$(IFS=', '; echo "${FAILED_LIST[*]}")"
  printf "%s\n\n" "$BORDER"
  exit 1
else
  printf "\n  ✔️  All services running.\n"
  printf "%s\n\n" "$BORDER"
  exit 0
fi
