# 🔁 AI Loop Engineering — Codex 驱动的系统观察循环

一个基于 Codex CLI 的 **Loop Engineering** 演示项目。AI 每轮循环自动检测 Linux 系统状态（负载、内存、进程等），生成自然语言观察记录，并通过 Checker 自我验证。

## 项目结构

```
├── intent.md          # 🎯 本轮目标定义
├── check.md           # ✅ 验证规则与成功标准
├── skill.md           # 📋 项目规范
├── output.md          # 📝 AI 产出的观察记录
├── state.md           # 🧠 运行状态与迭代历史
├── loop-cycle.sh      # 🔁 外循环脚本（5 阶段）
└── automation-daemon.sh  # ⏱ 自动触发器（每 60 秒）
```

## 循环流程

| 阶段 | 步骤 | 说明 |
|:---:|:---|:---|
| 1️⃣ | **Intent** | 读取目标定义 |
| 2️⃣ | **Context** | 获取上轮输出作为上下文 |
| 3️⃣ | **Action** | `codex exec` 生成系统观察 |
| 4️⃣ | **Observation** | `codex exec` 验证输出合规性 |
| 5️⃣ | **Adjustment** | 更新 state.md，持久化状态 |

## 快速开始

```bash
# 手动运行一轮
bash loop-cycle.sh

# 启动自动循环（每 60 秒一轮）
bash automation-daemon.sh
```

## 技术栈

- **Codex CLI** — Maker（生成）+ Checker（验证）
- **Bash** — 循环编排
- **Linux** — 运行环境

## 自定义

编辑 `intent.md` 修改目标，编辑 `check.md` 修改验证规则，循环逻辑无需改动。
