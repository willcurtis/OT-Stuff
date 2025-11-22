#!/usr/bin/env bash
#
# ot_discovery.sh — Safe-ish multi-protocol OT/BMS discovery wrapper for Nmap.
#
# Usage:
#   sudo ./scripts/ot_discovery.sh <CIDR>
#
# Example:
#   sudo ./scripts/ot_discovery.sh 10.10.0.0/16
#

set -euo pipefail

if [[ "$EUID" -ne 0 ]]; then
  echo "[ERROR] Please run as root (sudo)."
  exit 1
fi

if [[ -z "${1:-}" ]]; then
  echo "Usage: $0 <CIDR>"
  exit 1
fi

TARGET="$1"
TS=$(date +%Y%m%d_%H%M%S)
OUT="ot_scan_${TS}"

echo "[+] Starting OT-safe discovery scan on ${TARGET}"
echo "[+] Output prefix: ${OUT}"

nmap -sS -sU \
  -p 47808,502,102,161,1911,4911,44818,20000 \
  -sV \
  -O \
  --script=safe,discovery \
  --reason \
  --stats-every=30s \
  -oA "${OUT}" \
  "${TARGET}"

echo "[+] Completed. Output files:"
echo "    ${OUT}.nmap"
echo "    ${OUT}.xml"
echo "    ${OUT}.gnmap"
