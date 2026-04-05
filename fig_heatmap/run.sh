#!/usr/bin/env bash

STEPS="${1:-1000}"
mkdir -p ./results

echo "Running plot_hot_transformer_block.py with --steps $STEPS"
python plot_hot_transformer_block.py --steps "$STEPS"

echo "Done. Figures in results/"
