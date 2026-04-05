#!/usr/bin/env bash

DEFAULT_JOBS=16

if [ -z "$1" ]; then
  MAX_JOBS="$DEFAULT_JOBS"
else
  MAX_JOBS="$1"
fi

mkdir -p ./results ./logs

jobcount=0
for script in ./py/*.py; do
  [ -e "$script" ] || continue
  base=$(basename "$script" .py)

  python "$script" > "./logs/${base}.log" 2>&1 &

  ((jobcount++))
  if (( jobcount >= MAX_JOBS )); then
    wait -n || true
    ((jobcount--))
  fi
done

wait || true
echo "All done. Results in ./results/, logs in ./logs/"
