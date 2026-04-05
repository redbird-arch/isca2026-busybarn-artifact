#!/usr/bin/env bash

JOBS="${1:-16}"
mkdir -p ./results ./pic

echo "=== Phase 1: Generate experiments for all models ==="
for d in ../models/*/; do
  echo "Generating: $d"
  (cd "$d" && make generate_exp)
done

echo "=== Phase 2: Run all model experiments ==="
for d in ../models/*/; do
  echo "Running: $d"
  (cd "$d" && ./run.sh "$JOBS")
done

echo "=== Phase 3: Aggregate results ==="
python end_to_end.py

echo "=== Phase 4: Draw figure ==="
python endtoend_pic.py

echo "All done."
