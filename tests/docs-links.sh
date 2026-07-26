#!/usr/bin/env bash
# SKILL.md 和各 references 用 `xxx.md` 互相引用。断链 = AI 读到一半找不到路。
set -uo pipefail
cd "$(cd "$(dirname "${BASH_SOURCE[0]}")/../skills/engineering-project" && pwd)"

# 这些是项目产物或外部工具的文件名，不是本 skill 的 reference
EXTERNAL='^(spec|glossary|runbook|requirements|README|AGENTS|SKILL)\.md$'

REFS=$(grep -ohE 'references/[a-z-]+\.md' SKILL.md | sort -u)
[ -n "$REFS" ] || { echo "✗ SKILL.md 里一条 references/ 引用都没抓到 —— 抓取方式失效了"; exit 1; }

fail=0
n=0
for f in $REFS; do
  [ -f "$f" ] || { echo "✗ SKILL.md 引用了不存在的 $f"; fail=1; }
  n=$((n+1))
done
for f in $(grep -rhoE '`[a-z-]+\.md`' references/ | tr -d '`' | sort -u); do
  echo "$f" | grep -qE "$EXTERNAL" && continue
  [ -f "references/$f" ] || { echo "✗ references/ 里引用了不存在的 $f"; fail=1; }
done
[ $fail -eq 0 ] && echo "✓ 文档交叉引用全部可解析（SKILL.md 引了 $n 份）"
exit $fail
