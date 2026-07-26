# engineering-workflow

这个仓库本身是一套 skill：一份 `SKILL.md` 路由 + 17 份 `references/*.md` +
5 个 shell 脚本 + 一套语言无关的项目模板。

**它主张的东西必须先用在它自己身上。** 一个说"CI 必须挡住合并"的仓库自己没有 CI，
就没有任何说服力。

## 验证

```bash
bash tests/verbs-consistent.sh    # 标准动词在三处一致
bash tests/docs-links.sh          # 文档交叉引用没断
bash tests/journal-behaviour.sh   # journal.sh 三项检测真的会触发
for f in skills/*/scripts/*.sh install.sh; do bash -n "$f"; done
```

CI 在 **ubuntu 和 macos 两个 runner** 上跑这些。macOS 那个不是凑数——
BSD 工具链专门用来拦 GNU-only 的写法（见下）。

## 这个仓库的三条特殊约束

### 1. 脚本必须在 BSD 工具链上也能跑

已经踩过一次：`\s`、`stat -c`、`date -d`、`sed -i`、`readlink -f`、`xargs -r`
全是 GNU 的，在 macOS 上要么直接失败，要么**静默降级成错误答案**（更糟）。

写脚本时：

- 正则用 `[[:space:]]`，不用 `\s`
- `stat` / `date` 这类要写双分支：`GNU 形式 2>/dev/null || BSD 形式 2>/dev/null`
- 不用 `sed -i`（两边参数不兼容），写临时文件再 `mv`
- 不用 `readlink -f`、`xargs -r`
- 兜底失败时**要么报错要么明说跳过**，不要静默给一个错误答案

### 2. 改了动词就要改三处

`make` 的动词表同时出现在 `templates/project-skeleton/Makefile`、
`references/conventions.md`、`references/skeleton.md`。

这是**故意保留的重复**——两份文档各有教学场景。代价由
`tests/verbs-consistent.sh` 兜住：不一致就红。**不许在没有这个检查的前提下
制造新的文档重复。**

### 3. `SKILL.md` 每次会话都会整个进上下文

所以它必须短。目前 161 行。**加内容之前先问能不能删**——
细节属于 `references/`，`SKILL.md` 只负责分流和路由。
超过 200 行就必须动手瘦身。

同理 `templates/project-skeleton/AGENTS.md` 目前 140 行，
而 `handoff.md` 自己定的宪法上限是 150 行——已经逼近，加一节就要砍一节。

## 写测试

这个仓库的测试**必须带防空断言**。踩过一次：`verbs-consistent.sh` 因为路径错，
三个变量全是空字符串，空等于空，于是报绿——**在什么都没测到的情况下**。

所以每个测试先断言"输入抓到了东西"，再断言它们的关系。

新增测试之后，**把实现改坏跑一遍**，确认它真的会红。只断言"没成功"
而不断言失败原因的测试，会在实现被整个删掉时照样绿。

注意测试脚本自己开了 `pipefail`：被测脚本故意非零退出时（`journal.sh`
有悬空副作用就返回 1），`cmd | grep` 会整体判失败。先把输出抓进变量再断言。

## 禁止

- 不许在 `SKILL.md` 里堆细节 —— 放 `references/`
- 不许制造没有机器检查兜底的文档重复
- 不许用 GNU-only 的 shell 写法
- 不许写只断言退出码、不断言原因的测试
- 不许在 `templates/project-skeleton/` 里放任何真实密钥或个人路径

## 提交

`<类型>: <做了什么>`，类型用 `feat` / `fix` / `docs` / `test` / `chore`。
仓库是公开的，提交前扫一遍有没有个人路径、邮箱、密钥。
