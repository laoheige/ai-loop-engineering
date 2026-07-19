#!/bin/bash
# ===== Loop Engineering — Codex AI 驱动的外循环周期 =====

cd "$(dirname "$0")"

ROUND=$(($(wc -l < output.md 2>/dev/null || echo 0) + 1))
NOW=$(date '+%Y-%m-%d %H:%M:%S')

echo ""
echo "═══════════════════════════════════════════"
echo "  🔁 AI Loop — 第 ${ROUND} 轮  (${NOW})"
echo "═══════════════════════════════════════════"

# ═══════════════════════════════════════
# 阶段 1：Intent
# ═══════════════════════════════════════
echo ""
echo "─── [1/5] Intent（意图）──────────────"
INTENT=$(grep -A1 "^## 目标" intent.md | tail -1)
echo "  $INTENT"

# ═══════════════════════════════════════
# 阶段 2：Context
# ═══════════════════════════════════════
echo ""
echo "─── [2/5] Context（上下文）───────────"
PREV_OUTPUT=$(tail -1 output.md 2>/dev/null || echo "（无）")
echo "  上一条：$PREV_OUTPUT"

# ═══════════════════════════════════════
# 阶段 3：Action — AI Maker（codex exec）
# ═══════════════════════════════════════
echo ""
echo "─── [3/5] Action — AI Maker ──────────"
echo "  🧠 调用 Codex 生成内容..."

# 把 prompt 写入临时文件，通过 stdin 传给 codex
cat > /tmp/maker-prompt.txt << MAKERPROMPT
你是一个技术观察者。请完成以下任务：

在 /root/aidriver/output.md 文件末尾追加一行。

格式要求：YYYY-MM-DD HH:MM:SS | <一句话技术观察>

内容要求：
- 观察当前系统环境（date、uptime、进程数等信息）
- 每次必须写一条新的、不同的观察
- 不要重复已有的内容

已有内容：
$(cat output.md 2>/dev/null || echo '（暂无）')

请只输出你追加的那一行内容，不要输出其他解释。
MAKERPROMPT

codex exec - < /tmp/maker-prompt.txt \
  --skip-git-repo-check \
  --dangerously-bypass-approvals-and-sandbox \
  -C /root/aidriver 2>&1 | tail -5

echo "  ✅ Maker 完成"

# ═══════════════════════════════════════
# 阶段 4：Observation — AI Checker
# ═══════════════════════════════════════
echo ""
echo "─── [4/5] Observation — AI Checker ────"
echo "  🔍 调用 Codex 验证输出..."

cat > /tmp/checker-prompt.txt << CHECKERPROMPT
你是一个对抗性审查员。请验证 /root/aidriver/output.md 的最新内容。

验证规则：
$(cat check.md)

已有全部内容：
$(cat output.md 2>/dev/null || echo '（空）')

请逐条检查：
1. 格式是否正确（YYYY-MM-DD HH:MM:SS）？
2. 日期是否为 $(date '+%Y-%m-%d')？
3. 内容是否不重复？
4. 是否是一条真实的观察？

输出格式：先写 PASS 或 FAIL，再写理由。
CHECKERPROMPT

CHECKER_RESULT=$(codex exec - < /tmp/checker-prompt.txt \
  --skip-git-repo-check \
  --dangerously-bypass-approvals-and-sandbox \
  -C /root/aidriver 2>&1)

echo "$CHECKER_RESULT" | grep -v "WARNING\|Codex\|workdir\|model\|provider\|approval\|sandbox\|reasoning\|session\|tokens used"

if echo "$CHECKER_RESULT" | grep -qi "PASS"; then
    VERDICT="✅ AI Checker 验证通过"
elif echo "$CHECKER_RESULT" | grep -qi "FAIL"; then
    VERDICT="❌ AI Checker 验证失败"
else
    VERDICT="⚠️ AI Checker 结论不明"
fi

# ═══════════════════════════════════════
# 阶段 5：Adjustment
# ═══════════════════════════════════════
echo ""
echo "─── [5/5] Adjustment（调整）──────────"
TOTAL=$(wc -l < output.md 2>/dev/null || echo 0)
LAST_LINE=$(tail -1 output.md 2>/dev/null || echo "无")

cat > state.md << STATEEOF
# 🤖 AI Loop — 运行状态

| 组件 | 角色 | 状态 |
|------|------|------|
| 🎯 intent.md | 目标定义 | ✅ |
| ✅ check.md | 验证规则 | ✅ |
| 📋 skill.md | 项目规范 | ✅ |
| 🧠 AI Maker | codex exec 生成 | ✅ 已执行 |
| 🔍 AI Checker | codex 验证输出 | ${VERDICT} |
| 🧠 state.md | 持久记忆 | ✅ 已更新 |

## 迭代历史

$(for i in $(seq 1 $TOTAL); do
  LINE=$(sed -n "${i}p" output.md)
  echo "| ${i} | ${LINE} | ✅ |"
done)

## 当前状态
- 累计产出：${TOTAL} 条
- 最后输出：${LAST_LINE}
- 上轮结论：${VERDICT}
STATEEOF

echo "  ✅ state.md 已更新"
echo ""
echo "═══════════════════════════════════════════"
echo "  ✅ 第 ${TOTAL} 轮 AI Loop 完成"
echo "  📊 累计 AI 产出：${TOTAL} 条"
echo "═══════════════════════════════════════════"
