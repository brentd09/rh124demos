#!/bin\bash
# cpu_stress.sh — lightweight, tunable CPU stress for Linux (RHEL 10 friendly)
# Usage:
#   ./cpu_stress.sh [-d DURATION_SEC] [-w WORKERS] [-l LOAD_PERCENT] [-c CYCLE_MS]
# Defaults:
#   DURATION=60s, WORKERS=$(nproc), LOAD=100, CYCLE=100ms

set -u

DURATION=60
WORKERS="$(command -v nproc >/dev/null 2>&1 && nproc || echo 1)"
LOAD=100          # 1..100 (% of a CPU per worker)
CYCLE_MS=100      # duty-cycle period; smaller => smoother load

print_usage() {
  cat <<EOF
Usage: $0 [-d DURATION_SEC] [-w WORKERS] [-l LOAD_PERCENT] [-c CYCLE_MS]
  -d  Duration to run (seconds). Default: ${DURATION}
  -w  Number of worker loops (typically equals CPU cores). Default: ${WORKERS}
  -l  Target CPU load per worker (1-100). Default: ${LOAD}
  -c  Duty-cycle period in milliseconds (e.g., 50-200). Default: ${CYCLE_MS}
Examples:
  $0                    # full blast on all cores for 60s
  $0 -d 120 -w 4 -l 70  # 4 workers, ~70% each, for 2 minutes
  $0 -l 30 -c 50        # ~30% per worker with a tighter 50ms cycle
EOF
}

# Parse args
while getopts ":d:w:l:c:h" opt; do
  case "$opt" in
    d) DURATION="$OPTARG" ;;
    w) WORKERS="$OPTARG" ;;
    l) LOAD="$OPTARG" ;;
    c) CYCLE_MS="$OPTARG" ;;
    h) print_usage; exit 0 ;;
    \?) echo "Invalid option: -$OPTARG" >&2; print_usage; exit 1 ;;
    :)  echo "Option -$OPTARG requires an argument." >&2; print_usage; exit 1 ;;
  esac
done 2>/dev/null || true

# Validate
if ! [[ "$DURATION" =~ ^[0-9]+$ ]] || [ "$DURATION" -le 0 ]; then
  echo "DURATION must be a positive integer (seconds)." >&2; exit 1
fi
if ! [[ "$WORKERS" =~ ^[0-9]+$ ]] || [ "$WORKERS" -le 0 ]; then
  echo "WORKERS must be a positive integer." >&2; exit 1
fi
if ! [[ "$LOAD" =~ ^[0-9]+$ ]] || [ "$LOAD" -lt 1 ] || [ "$LOAD" -gt 100 ]; then
  echo "LOAD must be 1..100 (percent)." >&2; exit 1
fi
if ! [[ "$CYCLE_MS" =~ ^[0-9]+$ ]] || [ "$CYCLE_MS" -lt 10 ] || [ "$CYCLE_MS" -gt 1000 ]; then
  echo "CYCLE_MS must be 10..1000." >&2; exit 1
fi

# Compute duty cycle pieces
BUSY_MS=$(( CYCLE_MS * LOAD / 100 ))
IDLE_MS=$(( CYCLE_MS - BUSY_MS ))
if [ "$BUSY_MS" -eq 0 ]; then BUSY_MS=1; IDLE_MS=$((CYCLE_MS-1)); fi

# Helper: now in milliseconds (GNU date provides %3N)
now_ms() { date +%s%3N; }

# Worker loop: burn CPU for BUSY_MS, then sleep for IDLE_MS; repeat until timeout
worker() {
  local end_epoch_ms="$1"
  while :; do
    # Check overall timeout
    local t="$(now_ms)"
    [ "$t" -ge "$end_epoch_ms" ] && break

    # Busy section
    local start="$(now_ms)"
    local target=$(( start + BUSY_MS ))
    while [ "$(now_ms)" -lt "$target" ]; do :; done

    # Idle section
    if [ "$IDLE_MS" -gt 0 ]; then
      # sleep fractional seconds using awk (avoids bc/python dependencies)
      sleep "$(awk -v ms="$IDLE_MS" 'BEGIN{printf "%.3f", ms/1000}')"
    fi
  done
}

# Cleanup all background jobs on exit (Ctrl-C safe)
pids=()
cleanup() {
  for p in "${pids[@]:-}"; do
    kill "$p" >/dev/null 2>&1 || true
  done
}
trap cleanup EXIT INT TERM

echo "Starting CPU stress: duration=${DURATION}s workers=${WORKERS} load=${LOAD}% cycle=${CYCLE_MS}ms"
START_MS="$(now_ms)"
END_MS=$(( START_MS + DURATION*1000 ))

# Launch workers
for _ in $(seq 1 "$WORKERS"); do
  worker "$END_MS" &
  pids+=("$!")
done

# Wait for all
wait
echo "CPU stress complete."
