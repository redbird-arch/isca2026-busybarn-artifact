#!/usr/bin/env bash

JOBS="${1:-16}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

echo "============================================"
echo "  BusyBarn Quick Validation Test"
echo "  Figures: 8a, 10c, 11, 12(GPT)"
echo "  Max concurrent jobs: $JOBS"
echo "============================================"


echo ""
echo "=== [1/5] Fig. 8a: AllGather Communication ==="
cd "$SCRIPT_DIR/fig_communication"
make generate_exp
mkdir -p ./results ./logs
jobcount=0
for script in ./py/allgather_*.py; do
  [ -e "$script" ] || continue
  base=$(basename "$script" .py)
  python "$script" > "./logs/${base}.log" 2>&1 &
  jobcount=$((jobcount + 1))
  if (( jobcount >= JOBS )); then wait -n || true; jobcount=$((jobcount - 1)); fi
done
wait || true
python allgather_synthetic_pic.py
echo "[1/5] Done: pic/allgather_synthetic.pdf"


echo ""
echo "=== [2/5] Fig. 10c: Power/Fault Sensitivity ==="
cd "$SCRIPT_DIR/fig_intra_power"
make generate_exp
./run.sh "$JOBS"
make draw_pic
echo "[2/5] Done: pic/intra_mapping_power_pic.pdf"


echo ""
echo "=== [3/5] Fig. 11: Workload Distribution Heatmap ==="
cd "$SCRIPT_DIR/fig_heatmap"
./run.sh 1000
echo "[3/5] Done: results/hot_transformer_block_combined_step1000.pdf"


echo ""
echo "=== [4/4] Fig. 12 (GPT only): End-to-End ==="
for d in intra_mapping_gpt_prefill intra_mapping_gpt_decode; do
  echo "  Generating: models/$d"
  cd "$SCRIPT_DIR/models/$d"
  make generate_exp
done
for d in intra_mapping_gpt_prefill intra_mapping_gpt_decode; do
  echo "  Running: models/$d"
  cd "$SCRIPT_DIR/models/$d"
  ./run.sh "$JOBS"
done
cd "$SCRIPT_DIR/fig_endtoend"
python end_to_end.py
python endtoend_pic_gpt.py
echo "[4/4] Done: fig_endtoend/endtoend_gpt.pdf"


echo ""
echo "============================================"
echo "  Quick validation complete."
echo "============================================"

echo ""
echo "=== Collecting results ==="
"$SCRIPT_DIR/collect_results.sh"
