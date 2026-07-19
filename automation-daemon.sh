#!/bin/bash
# ===== 🔁 AI Loop 自动触发器 =====
# 每 60 秒触发一次外循环，使用 Codex AI 驱动

LOOP_DIR="$(cd "$(dirname "$0")" && pwd)"
PID_FILE="$LOOP_DIR/automation.pid"

echo "$$" > "$PID_FILE"
echo "🚀 AI Loop 自动触发器启动（PID: $$）"
echo "⏱  间隔：60 秒"

while true; do
    cd "$LOOP_DIR" && bash loop-cycle.sh
    sleep 60
done
