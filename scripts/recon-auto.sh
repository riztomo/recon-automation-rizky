#!/bin/bash

# ==============================
# Recon Automation Script
# By: Rizky
# Tools: subfinder, anew, httpx
# ==============================

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

INPUT_FILE="$BASE_DIR/input/domains.txt"

OUTPUT_ALL="$BASE_DIR/output/all-subdomains.txt"
OUTPUT_LIVE="$BASE_DIR/output/live.txt"

LOG_PROGRESS="$BASE_DIR/logs/progress.log"
LOG_ERRORS="$BASE_DIR/logs/errors.log"

TMP_SUBS="$BASE_DIR/output/tmp_subs.txt"

# Create directories if missing
mkdir -p "$BASE_DIR/input" "$BASE_DIR/output" "$BASE_DIR/logs"

# Timestamp function
timestamp() {
    date +"[%Y-%m-%d %H:%M:%S]"
}

log_progress() {
    echo "$(timestamp) $1" | tee -a "$LOG_PROGRESS"
}

log_error() {
    echo "$(timestamp) ERROR: $1" | tee -a "$LOG_ERRORS" >&2
}

# Check required tools
check_tool() {
    command -v "$1" > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        log_error "Missing required tool: $1"
        exit 1
    fi
}

log_progress "===== Recon Automation Started ====="

check_tool subfinder
check_tool anew
check_tool httpx
check_tool tee

# Validate input file
if [ ! -f "$INPUT_FILE" ]; then
    log_error "Input file not found: $INPUT_FILE"
    exit 1
fi

if [ ! -s "$INPUT_FILE" ]; then
    log_error "Input file is empty: $INPUT_FILE"
    exit 1
fi

# Ensure output files exist
touch "$OUTPUT_ALL" "$OUTPUT_LIVE" "$LOG_PROGRESS" "$LOG_ERRORS"

log_progress "Input domains file: $INPUT_FILE"
log_progress "Output all subdomains: $OUTPUT_ALL"
log_progress "Output live hosts: $OUTPUT_LIVE"

# Cleanup temp file
rm -f "$TMP_SUBS"
touch "$TMP_SUBS"

# Enumerate subdomains
log_progress "Starting subdomain enumeration with subfinder..."

while read -r domain; do
    domain=$(echo "$domain" | xargs)

    # Skip empty lines
    if [ -z "$domain" ]; then
        continue
    fi

    log_progress "Enumerating subdomains for: $domain"

    subfinder -d "$domain" -silent 2>>"$LOG_ERRORS" \
        | tee -a "$TMP_SUBS" >/dev/null

done < "$INPUT_FILE"

log_progress "Subfinder enumeration completed."

# Deduplicate using anew
log_progress "Deduplicating results using anew..."

cat "$TMP_SUBS" 2>> "$LOG_ERRORS" | anew "$OUTPUT_ALL" 2>> "$LOG_ERRORS" \
    | tee -a > /dev/null

log_progress "Deduplication completed. Saved into: $OUTPUT_ALL"

# Filter live using httpx
log_progress "Filtering live hosts using httpx..."

httpx -l "$OUTPUT_ALL" -silent 2>>"$LOG_ERRORS" \
    | tee "$OUTPUT_LIVE" | tee -a > /dev/null

log_progress "Live host filtering completed. Saved into: $OUTPUT_LIVE"

# Final counts
TOTAL_SUBS=$(wc -l < "$OUTPUT_ALL")
TOTAL_LIVE=$(wc -l < "$OUTPUT_LIVE")

# Cleanup temp file
rm -f "$TMP_SUBS"

log_progress "===== Recon Automation Finished ====="
log_progress "Total unique subdomains: $TOTAL_SUBS"
log_progress "Total live hosts: $TOTAL_LIVE"

echo ""
echo "========== FINAL RESULTS =========="
echo "Unique subdomains saved in: $OUTPUT_ALL"
echo "Live hosts saved in:        $OUTPUT_LIVE"
echo "----------------------------------"
echo "Total unique subdomains: $TOTAL_SUBS"
echo "Total live hosts:       $TOTAL_LIVE"
echo "Logs:"
echo " Progress log: $LOG_PROGRESS"
echo " Error log:    $LOG_ERRORS"
echo "=================================="
