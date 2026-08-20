#!/usr/bin/env bash
# Robustly wait for a LAVA job to reach a terminal state.
#
# `lavacli jobs wait` issues XML-RPC polls with a hard-coded 20s HTTP read
# timeout and aborts the whole wait (exit 1) on a single slow/timed-out poll.
# Long-running jobs — e.g. pushing a multi-hundred-MB OSTree commit archive over
# adb — poll many times and reliably trip this, failing the step even though the
# job is healthy and still running.
#
# Poll `jobs show` with short requests instead, tolerate transient query
# failures, and only give up after a hard deadline. The job's health and test
# results are validated separately by the "Fail if any LAVA job ..." step, so
# reaching a terminal state here is all we need.
set -u

ID="${1:?usage: wait-job.sh <job-id> [timeout-seconds]}"
TIMEOUT="${2:-5400}"   # 90 minutes by default
DEADLINE=$(( $(date +%s) + TIMEOUT ))

while :; do
  STATE=$(lavacli --identity lava-ci jobs show "$ID" 2>/dev/null | awk '/^[Ss]tate/{print tolower($NF)}')
  case "$STATE" in
    finished|canceled|cancelled)
      echo "LAVA job $ID: $STATE"
      exit 0
      ;;
    "")
      echo "LAVA job $ID: state query failed (transient), retrying"
      ;;
    *)
      echo "LAVA job $ID: $STATE"
      ;;
  esac
  if [ "$(date +%s)" -ge "$DEADLINE" ]; then
    echo "LAVA job $ID: timed out after ${TIMEOUT}s waiting to finish" >&2
    exit 1
  fi
  sleep 15
done
