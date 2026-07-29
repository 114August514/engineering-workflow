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
bash tests/ci-scope-consistent.sh # CI relevance receipt 与双平台入口一致
for f in skills/*/scripts/*.sh install.sh; do bash -n "$f"; done
```

CI 在 **ubuntu 和 macos 两个 runner** 上跑这些。macOS 那个不是凑数——
BSD 工具链专门用来拦 GNU-only 的写法（见下）。


### CI 相关性

每个 PR 和 Gate receipt 使用同一个格式：

```text
ci-scope: required=<checks|none>; advisory=<checks|none>; n/a=<checks|none>; reason=<why>
```

- `required`：失败能推翻当前 acceptance；只在 merge、gate、tag 等终态动作前等待相关 checks。
- `advisory`：有信息价值，不阻塞独立工作。
- `n/a`：与当前变更无因果关系。

pending CI 不改变 task state。文档或研究变更不得因为无关 runner pending 而停止；修改 shell、
workflow 或跨平台行为时，Ubuntu/macOS 对应检查是 required。Domain CI 只验证本仓产品行为，
不重新引入已经删除的一次性研究迁移 checker，也不根据路径自动构建 universal wait。

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
- **`$VAR` 后面紧跟中文标点时必须写成 `${VAR}`** —— macOS 自带 bash 3.2，
  它会把后面的 UTF-8 字节吃进变量名，于是 `$ADAPTER（` 变成变量 `ADAPTER（`，
  在 `set -u` 下直接 unbound variable。bash 5 不会，所以本地测不出来。
  这一条是 CI 第一次跑就抓到的

### 2. 改了动词就要改三处

`make` 的动词表同时出现在 `templates/project-skeleton/Makefile`、
`references/conventions.md`、`references/skeleton.md`。

这是**故意保留的重复**——两份文档各有教学场景。代价由
`tests/verbs-consistent.sh` 兜住：不一致就红。**不许在没有这个检查的前提下
制造新的文档重复。**

### 3. 行数是烟雾报警器，不是预算

`SKILL.md` 每次会话都整个进上下文。但**约束不是 token**（200 行中文 ≈ 5k token，
在 20 万上下文里不算什么），**是注意力**：一份长路由文档会稀释信号。

所以真正的规则是**职责划分**，不是行数：

- `SKILL.md` 只放三样：分流、路由表、硬规则。
  任何解释、例子、理由都属于 `references/`
- `templates/project-skeleton/AGENTS.md` 只放约束和指针，
  展开的做法放 `templates/project-skeleton/docs/conventions.md`
  （它随项目走，用的人不需要装这个 skill）

行数（SKILL.md 200 / AGENTS.md 150）只当烟雾报警器：**报警时先问"哪部分
放错了地方"，而不是"能不能把预算调大"。** 靠压缩句子去凑行数是绕过规则。

### 4. 卫星 skill 只许是薄壳

仓库有 5 个 skill：主 skill `engineering-project`（流程）+ 四个卫星
`frontend-code` / `backend-code` / `api-contract` / `repo-init`（精准触发 + 转发）。

**拆的是触发壳，不是内容。** 量过：19 份 references 之间有 48 条交叉引用，
按话题真拆内容会有 18 条（38%）跨界；被引最多的三份恰恰是**横切**的
（`proportion.md` 12 次、`audit.md` 9 次、`reuse.md` 6 次），
真拆只能靠复制——那违反本仓库自己的"无机器检查的重复一律禁止"。

所以卫星里**一个字的规范内容都不放**，只有：narrow description + 两三行转发。
`tests/satellites-thin.sh` 强制这一点：

- ≤ 40 行，超了就是内容跑错地方了
- frontmatter 的 `name` 必须等于目录名
- description ≥ 120 字符（卫星存在的唯一理由就是精准触发）
- 指向的 reference 必须存在
- **必须指向 `always.md`** —— 否则只触发卫星时，三条横切规则就丢了
- 主 SKILL.md 不许再内联那三条（`always.md` 是唯一事实源）

加新卫星 = 加一个目录 + 一个 SKILL.md，别顺手往里写内容。

## 写测试

这个仓库的测试**必须带防空断言**。踩过一次：`verbs-consistent.sh` 因为路径错，
三个变量全是空字符串，空等于空，于是报绿——**在什么都没测到的情况下**。

所以每个测试先断言"输入抓到了东西"，再断言它们的关系。

新增测试之后，**把实现改坏跑一遍**，确认它真的会红。只断言"没成功"
而不断言失败原因的测试，会在实现被整个删掉时照样绿。

注意测试脚本自己开了 `pipefail`：被测脚本故意非零退出时（`journal.sh`
有悬空副作用、或拒绝非法 slug 时都返回 1），`"$J" ... | grep` 会**整体判失败**——
挂的是退出码，不是被断言的行为。**一律走 `out()` 包装**，不要写裸管道。
这个坑踩过两次：第一次修完之后，新加断言时又写成了裸管道。

**报错要指对地方。** `templates-valid.sh` 曾经在 macOS 上把「PyYAML 没装」
报成「YAML 不合法」——依赖缺失被说成内容错误，人会去改模板而不是装依赖。
凡是依赖外部工具的检查，都要先探测能力再干活，两种失败给两种措辞。

**看测试结果时不要 `| tail -1`。** 失败时汇总行根本不会打印，
只 tail 最后一行会看到一个 ✓ 然后以为过了 —— 这个也踩过。

## 禁止

- 不许在 `SKILL.md` 里堆细节 —— 放 `references/`
- 不许制造没有机器检查兜底的文档重复
- 不许用 GNU-only 的 shell 写法
- 不许写只断言退出码、不断言原因的测试
- 不许在 `templates/project-skeleton/` 里放任何真实密钥或个人路径

## 提交

`<类型>: <做了什么>`，类型用 `feat` / `fix` / `docs` / `test` / `chore`。
仓库是公开的，提交前扫一遍有没有个人路径、邮箱、密钥。
