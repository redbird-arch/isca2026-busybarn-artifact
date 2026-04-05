#!/usr/bin/env bash

JOBS="${1:-16}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

echo "============================================"
echo "  BusyBarn Artifact Evaluation"
echo "  Max concurrent jobs: $JOBS"
echo "============================================"


echo ""
echo "=== Phase 1: Old backend experiments ==="

(echo "[fig_communication] generate + run + plot"
 cd fig_communication && make generate_exp && make run_scripts && make draw_pic) &

(echo "[fig_intra_ch] generate + run + plot"
 cd fig_intra_ch && make generate_exp && ./run.sh "$JOBS" && make draw_pic) &

(echo "[fig_intra_coreshape] generate + run + plot"
 cd fig_intra_coreshape && make generate_exp && ./run.sh "$JOBS" && make draw_pic) &

(echo "[fig_intra_power] generate + run + plot"
 cd fig_intra_power && make generate_exp && ./run.sh "$JOBS" && make draw_pic) &

(echo "[fig_intra_multifaults] generate + run + plot"
 cd fig_intra_multifaults && make generate_exp && ./run.sh "$JOBS" && make draw_pic) &

wait || true
echo "Phase 1 complete."


echo ""
echo "=== Phase 2: End-to-end model experiments ==="

for d in models/*/; do
  (cd "$d" && make generate_exp)
done

for d in models/*/; do
  echo "Running: $d"
  (cd "$d" && ./run.sh "$JOBS") &
done
wait || true

echo "[fig_endtoend] aggregate + plot"
(cd fig_endtoend && python end_to_end.py && python endtoend_pic.py)

echo "Phase 2 complete."


echo ""
echo "=== Phase 3: New backend experiments ==="

(echo "[fig_convergence] SA convergence + brute baselines + plot"
 cd fig_convergence && ./run.sh) &

(echo "[fig_heatmap] heatmap (runs SA internally)"
 cd fig_heatmap && ./run.sh 1000) &

wait || true

echo "[fig_ablation] ablation study + runtime breakdown (32 runs, memory intensive)"
(cd fig_ablation && ./run.sh "$JOBS" && make draw_pic)

echo ""
echo "============================================"
echo "  All figures generated successfully."
echo "============================================"

echo ""
echo "=== Collecting results ==="
./collect_results.sh
