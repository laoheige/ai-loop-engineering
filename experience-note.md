# 🤖 AI Loop Engineering — 实战经验总结

> 日期：2026-07-19 | 项目：ai-loop-engineering https://github.com/laoheige/ai-loop-engineering

---

## 一、项目概况

一个基于 **Codex CLI** 的 **Loop Engineering** 演示项目。AI 每轮循环自动检测 Linux 系统状态，生成自然语言观察记录，并通过 Checker 自我验证。最终产出 7 条系统观察，已推送到 GitHub。

---

## 二、架构设计 — 5 阶段循环

```
[1/5] Intent      →   读取目标定义（intent.md）
[2/5] Context     →   获取上轮输出作为上下文
[3/5] Action      →   AI Maker 生成观察（codex exec）
[4/5] Observation →   AI Checker 验证合规性（codex exec）
[5/5] Adjustment  →   更新状态持久化（state.md）
         ↑_____________________________↓
               循环往复
```

### 文件职责分离原则

| 文件 | 职责 | 类比 |
|:---|:---|---:|
| `intent.md` | 🎯 **目标** — 做什么 | 产品需求 |
| `check.md` | ✅ **规则** — 怎么检查 | QA 测试用例 |
| `skill.md` | 📋 **规范** — 怎么做 | 开发规范文档 |
| `output.md` | 📝 **产出** — AI 成果 | 交付物 |
| `state.md` | 🧠 **状态** — 运行记录 | 数据库 |

**关键经验：** 成功标准应放在 `check.md` 而非 `intent.md`，保持单一职责。

---

## 三、踩坑记录 & 修复

### 🕳️ 坑 1：intent.md 的 grep 匹配失败

**现象：** `bash loop-cycle.sh` 后 `[1/5] Intent` 阶段不显示内容

**原因：** 脚本里写的是 `grep "^本轮目标"`，但 intent.md 的实际标题是 `## 目标`，字符串不匹配

**修复：** 统一改为 `grep "^## 目标"`

### 🕳️ 坑 2：codex exec 在循环中不工作

**现象：** `loop-cycle.sh` 调用 `codex exec` 卡住，无法生成内容

**原因：** 脚本里启动的 `codex exec` 是另一个 AI 实例，但当前环境已经是 Codex AI，嵌套调用在 CLI 环境中不通

**修复：** 人工接管 Maker 阶段 — 手动检查系统状态并写入 output.md

### 🕳️ 坑 3：时间格式不一致

**现象：** 初始只有日期 `YYYY-MM-DD`，缺少时分秒

**修复：** 统一改为 `YYYY-MM-DD HH:MM:SS`，同步更新所有相关文件

### 🕳️ 坑 4：绝对路径隐私泄露

**现象：** 脚本中使用 `/root/aidriver` 硬编码路径，推送到 GitHub 会暴露服务器目录结构

**修复：** 改用 `$(dirname "$0")` 相对路径

---

## 四、GitHub 上传流程

```bash
# 1. 隐私清理 — 替换绝对路径
sed -i 's|/root/aidriver|$(dirname "$0")|' *.sh

# 2. 创建仓库（GitHub API）
curl -H "Authorization: token <PAT>" \
  -d '{"name":"ai-loop-engineering"}' \
  https://api.github.com/user/repos

# 3. 推送
git init && git add -A
git commit -m "🎉 init"
git remote add origin <repo-url>
git branch -m master main
git push -u origin main
```

---

## 五、产出成果

共完成 **7 轮** 系统观察，记录了傍晚时段系统负载的完整变化：

| 轮次 | 时间 | 负载 | 关键特征 |
|:---:|:---:|:---:|:---|
| 1 | 17:44 | 0.35 | 轻载基线 |
| 2 | 17:46 | 0.87 ↑ | 负载飙升 |
| 3 | 18:16 | 0.39 ↓ | 回落至轻载 |
| 4 | 18:17 | 0.18 ↓ | 日内最低点 |
| 5 | 18:20 | 0.29 ↑ | 小幅反弹 |
| 6 | 18:29 | **0.07** 🔽 | 日内新低 |
| 7 | 18:31 | 0.15 ↑ | 温和反弹 |

---

## 六、核心经验教训

1. **文件职责要单一** — intent.md 只放目标，check.md 只放规则，别混在一起
2. **脚本里的 grep 模式要跟文件内容精确匹配** — 肉眼看似一样的字符串，可能因空格/特殊字符匹配不上
3. **绝对路径是隐私大敌** — 上传前必须扫一遍所有文件，把硬编码路径替换掉
4. **Codex CLI 的嵌套调用有限制** — 在 Codex AI 会话里启动另一个 codex exec 实例不一定能正常工作
5. **API Token 用完即弃** — GitHub Personal Access Token 不要留在脚本或历史里，推送完就撤销
6. **格式规范要统一下沉** — 时间格式这类细节要在 check.md 里定义，并通过 Checker 阶段自动验证，避免人工检查遗漏
