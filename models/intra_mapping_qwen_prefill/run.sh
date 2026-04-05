#!/usr/bin/env bash
DEFAULT_JOBS=16
[ -n "$1" ] && MAX_JOBS="$1" || MAX_JOBS="$DEFAULT_JOBS"
mkdir -p ./results
jobcount=0
for script in ./py/*.py; do
  [ -e "$script" ] || continue
  base=$(basename "$script" .py)
  python "$script" > "./results/${base}.txt" 2>&1 &
  ((jobcount++))
  if (( jobcount >= MAX_JOBS )); then wait -n || true; ((jobcount--)); fi
done
wait || true
echo "All done. Results in ./results/"
