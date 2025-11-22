#!/usr/bin/env bash
#
# bacnet_discovery.sh — BACnet-focused discovery wrapper using Nmap NSE.
#
# Usage:
#   sudo ./scripts/bacnet_discovery.sh <CIDR or IP>
#
# Example:
#   sudo ./scripts/bacnet_discovery.sh 10.10.20.0/24
#

set -euo pipefail

if [[ "$EUID" -ne 0 ]]; then
  echo "[ERROR] Please run as root (sudo)."
  exit 1
fi

if [[ -z "${1:-}" ]]; then
  echo "Usage: $0 <CIDR or IP>"
  exit 1
fi

TARGET="$1"
TS=$(date +%Y%m%d_%H%M%S)
OUT="bacnet_scan_${TS}"

echo "[+] Starting BACnet discovery scan on ${TARGET}"
echo "[+] Output prefix: ${OUT}"

nmap -sU \
  -p 47808 \
  --script=bacnet-info \
  --reason \
  --stats-every=30s \
  -oA "${OUT}" \
  "${TARGET}"

echo "[+] Completed. Output files:"
echo "    ${OUT}.nmap"
echo "    ${OUT}.xml"
echo "    ${OUT}.gnmap"
echo ""
echo "[!] Tip: Add 'bacnet-discover' to --script for deeper (more intrusive) enumeration if approved."
